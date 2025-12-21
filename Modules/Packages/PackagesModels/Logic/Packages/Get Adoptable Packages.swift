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

                let unprocessedAdoptionCandidates: Set<AdoptionCandidateWithAssociatedExecutable> = await extractAdoptionCandidates(from: parsedCasksJson)

                AppConstants.shared.logger.debug("Successfully extracted unprocessed adoption candidates")

                // Here, we will compare the extracted adoption candidates with the apps we have installed
                do
                {
                    let installedApps: Set<String> = try await self.getInstalledApps()

                    let processedAdoptableCasks: [AdoptableApp] = await getAdoptableAppsFromAvailableCasks(installedApps: installedApps, unprocessedAdoptionCandidates: unprocessedAdoptionCandidates)

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

    /// One step before creating adoption candidates
    /// Will get all adoption candidates, not yet associated with any installed executable
    /// Later, we will see which adoption candidates have executables that correspond with any installed app, and cluster any that correspond to more than one cask
    private struct AdoptionCandidateWithAssociatedExecutable: Hashable
    {
        let adoptionCandidate: AdoptableApp.AdoptionCandidate
        let appExecutableForCandidate: String
    }

    /// Get adoption candidates, along with their associated executables
    /// We will be finding duplicates later when comparing with the contents of the `Applications` folder
    private nonisolated
    func extractAdoptionCandidates(
        from parsedCasks: [BrewPackage.PackageCommandOutput.Casks]
    ) async -> Set<AdoptionCandidateWithAssociatedExecutable>
    {
        return Set(parsedCasks.compactMap
        { parsedCask in
            if let executableForCandidate: String = parsedCask.executableName
            {
                return .init(adoptionCandidate: .init(caskName: parsedCask.token, caskDescription: parsedCask.desc), appExecutableForCandidate: executableForCandidate)
            }
            else
            {
                AppConstants.shared.logger.info("Extracted adoption candidate (\(parsedCask.token) has no executable defined - skipping")
                
                return nil
            }
        })
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
        unprocessedAdoptionCandidates: Set<AdoptionCandidateWithAssociatedExecutable>
    ) async -> [AdoptableApp]
    {
        /// Get those adoption candidates whose executables match executables found in the `Applications` folder
        let relevantAdoptionCandidates: Set<AdoptionCandidateWithAssociatedExecutable> = unprocessedAdoptionCandidates.filter
        { unprocessedAdoptionCandidate in
            installedApps.contains(unprocessedAdoptionCandidate.appExecutableForCandidate)
        }

        /// Only get the names of installed packages to make the comparing faster
        let caskNamesOfInstalledPackages: Set<String> = await .init(successfullyLoadedCasks.map { $0.name })

        /// Filter out packages that are already included in the Cask tracker (which means they are already installed)
        let adoptionCandidatesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCackTracker: Set<AdoptionCandidateWithAssociatedExecutable> = relevantAdoptionCandidates.filter { !caskNamesOfInstalledPackages.contains($0.appExecutableForCandidate) }
        
        /// Transform the adoption candidates into usable ``AdoptableApp``
        let finalProcessedAdoptableApps: Set<AdoptableApp> = await constructFinalAdoptableAppsFromUnprocessedCandidates(unprocessedAdoptionCandidates: adoptionCandidatesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCackTracker)

        print("Finally processed adoption candidates: \(adoptionCandidatesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCackTracker)")

        var adoptableAppsWithConstructedBundles: [BrewPackagesTracker.AdoptableApp] = .init()

        await withTaskGroup(of: AdoptableApp.self)
        { taskGroup in
            for adoptableApp in finalProcessedAdoptableApps
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

    /// Take the unprocessed adoption candidates, and make them into ``AdoptableApp`` with a list of potential adoptable Casks
    private nonisolated
    func constructFinalAdoptableAppsFromUnprocessedCandidates(
        unprocessedAdoptionCandidates: Set<AdoptionCandidateWithAssociatedExecutable>
    ) async -> Set<BrewPackagesTracker.AdoptableApp>
    {
        return Set(
            Dictionary(grouping: unprocessedAdoptionCandidates) { $0.appExecutableForCandidate }.map
            {
                .init(adoptionCandidates: $0.value.map { $0.adoptionCandidate }, appExecutable: $0.key)
            }
        )
    }
}
