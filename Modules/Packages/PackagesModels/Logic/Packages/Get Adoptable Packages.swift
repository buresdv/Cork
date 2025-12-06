//
//  Get Adoptable Packages.swift
//  Cork
//
//  Created by David Bureš - P on 03.10.2025.
//

import CorkShared
import Foundation
import SwiftData

public extension BrewPackagesTracker
{
    enum AdoptableCasksLoadingError: LocalizedError
    {
        case couldNotGetAllCasksData(error: String)
        case couldNotParseAllCasksData(error: String)
        case couldNotProcessCasksData(error: String)
        case couldNotGetContentsOfApplicationsFolder(error: String)
    }

    enum HomebrewDataCacheUsePolicy
    {
        case useCachedData
        case forceDataFetch

        var cachePolicy: URLRequest.CachePolicy
        {
            switch self
            {
            case .useCachedData:
                return .returnCacheDataElseLoad
            case .forceDataFetch:
                return .reloadIgnoringLocalCacheData
            }
        }
    }

    /// Get a list of casks that can be adopted into the Homebrew updating mechanism
    nonisolated
    func getAdoptableCasks(
        cacheUsePolicy: HomebrewDataCacheUsePolicy
    ) async throws(AdoptableCasksLoadingError) -> [AdoptableApp]
    {
        do
        {
            let allCasksJson: Data = try await self.loadAllCasksJson(cachingPolicy: cacheUsePolicy)

            AppConstants.shared.logger.debug("Successfully loaded all Casks JSON")

            do
            {
                let parsedCasksJson: [BrewPackage.PackageCommandOutput.Casks] = try await self.parseCasksJson(jsonAsData: allCasksJson)

                AppConstants.shared.logger.debug("Successfully parsed all Casks")

                let processedAvailableCasks: Set<AdoptableApp> = await processParsedAvailableCasks(from: parsedCasksJson)

                AppConstants.shared.logger.debug("Successfully processed available Casks")

                do
                {
                    let installedApps: Set<String> = try await self.getInstalledApps()

                    let processedAdoptableCasks: [AdoptableApp] = await getAdoptableAppsFromAvailableCasks(
                        installedApps: installedApps,
                        allAvailableCasks: processedAvailableCasks
                    )

                    return processedAdoptableCasks
                }
                catch let applicationDirectoryAccessingError
                {
                    throw AdoptableCasksLoadingError.couldNotGetContentsOfApplicationsFolder(error: applicationDirectoryAccessingError.localizedDescription)
                }
            }
            catch let allCasksParsingError
            {
                throw AdoptableCasksLoadingError.couldNotParseAllCasksData(error: allCasksParsingError.localizedDescription)
            }
        }
        catch let allCasksDataLoadingError
        {
            throw .couldNotGetAllCasksData(error: allCasksDataLoadingError.localizedDescription)
        }
    }

    /// Download a JSON list of all available casks
    private nonisolated
    func loadAllCasksJson(
        cachingPolicy: HomebrewDataCacheUsePolicy
    ) async throws(DataDownloadingError) -> Data
    {
        return try await downloadDataFromURL(.init(string: "https://formulae.brew.sh/api/cask.json")!, cachingPolicy: cachingPolicy.cachePolicy)
    }

    enum CasksJsonParsingError: Error
    {
        case failedToParseJson(error: String)
    }

    /// Parse the downloaded Casks JSON into usable objects
    private nonisolated
    func parseCasksJson(
        jsonAsData: Data
    ) async throws(CasksJsonParsingError) -> [BrewPackage.PackageCommandOutput.Casks]
    {
        let decoder: JSONDecoder = {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()

        do
        {
            return try decoder.decode([BrewPackage.PackageCommandOutput.Casks].self, from: jsonAsData)
        }
        catch let casksJsonParsingError
        {
            throw .failedToParseJson(error: casksJsonParsingError.localizedDescription)
        }
    }
    
    /// Take the array that contains all Casks, and transform them into a list of Cask names, associated with their executable names for comparing with the contents of the Applications folder
    private nonisolated
    func processParsedAvailableCasks(
        from parsedCasks: [BrewPackage.PackageCommandOutput.Casks]
    ) async -> Set<AdoptableApp>
    {
        var resultArray: Set<AdoptableApp> = .init()

        for parsedCask in parsedCasks
        {
            if let executableName = parsedCask.executableName
            {
                AppConstants.shared.logger.debug("Processed potential adoptable cask: \(parsedCask.token) - \(executableName)")

                resultArray.insert(
                    .init(
                        caskName: parsedCask.token,
                        description: parsedCask.desc,
                        appExecutable: executableName
                    )
                )
            }
            else
            {
                AppConstants.shared.logger.debug("Processed potential adoptable cask: \(parsedCask.token) - NO EXECUTABLE PROVIDED")
            }
        }

        return resultArray
    }

    enum AppDirectoryReadingError: Error
    {
        case generic(error: String)
    }

    /// Get the names for executables in the Applications directory
    private nonisolated
    func getInstalledApps() async throws(AppDirectoryReadingError) -> Set<String>
    {
        do
        {
            let contentsOfApplicationsFolder: [URL] = try FileManager.default.contentsOfDirectory(at: .applicationDirectory, includingPropertiesForKeys: [.isExecutableKey], options: .skipsHiddenFiles)

            return Set(contentsOfApplicationsFolder.map { $0.lastPathComponent })
        }
        catch let applicationDirectoryReadingError
        {
            AppConstants.shared.logger.error("Failed to get contents of Applications directory: \(applicationDirectoryReadingError)")

            throw .generic(error: applicationDirectoryReadingError.localizedDescription)
        }
    }

    /// Compare the contents of the Applications folder with the available casks, and also remove installed casks using the Cask tracker
    private nonisolated
    func getAdoptableAppsFromAvailableCasks(
        installedApps: Set<String>,
        allAvailableCasks: Set<AdoptableApp>
    ) async -> [AdoptableApp]
    {
        /// Filter out those available Casks whose executables match those in the Applications folder
        let caskNamesOfAppsNotInstalledThroughHomebrew: Set<AdoptableApp> = allAvailableCasks.filter
        { adoptableCask in
            installedApps.contains(adoptableCask.appExecutable)
        }

        /// Only get the names of installed packages to make the comparing faster
        let installedCaskNames: Set<String> = await .init(successfullyLoadedCasks.map { $0.name })

        /// Filter out packages that are already included in the Cask tracker (which means they are already installed) and those that contain the charactzer `@` (betas, etc.)
        let caskNamesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCaskTracker: Set<AdoptableApp> = caskNamesOfAppsNotInstalledThroughHomebrew.filter { !installedCaskNames.contains($0.caskName) }.filter { !$0.caskName.contains("@") }

        print("Finally processed casks: \(caskNamesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCaskTracker)")

        var adoptableAppsWithConstructedBundles: [BrewPackagesTracker.AdoptableApp] = .init()

        await withTaskGroup(of: AdoptableApp.self)
        { taskGroup in
            for adoptableApp in caskNamesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCaskTracker
            {
                taskGroup.addTask
                {
                    var mutableAdoptableApp: BrewPackagesTracker.AdoptableApp = adoptableApp

                    mutableAdoptableApp.app = await mutableAdoptableApp.constructAppBundle()

                    return mutableAdoptableApp
                }

                for await constructedAdoptableApp in taskGroup
                {
                    adoptableAppsWithConstructedBundles.append(
                        constructedAdoptableApp
                    )
                }
            }
        }

        return adoptableAppsWithConstructedBundles
    }
}
