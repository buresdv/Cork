//
//  Get Adoptable Packages.swift
//  Cork
//
//  Created by David Bureš - P on 03.10.2025.
//

import Foundation
import CorkShared

extension BrewPackagesTracker
{
    /// Get a list of casks that can be adopted into the Homebrew updating mechanism
    func getAdoptableCasks() async throws -> Set<AdoptableCaskComparable>
    {
        let allCasksJson: Data = try await self.loadAllCasksJson()
        
        AppConstants.shared.logger.debug("Successfully loaded all Casks JSON")
        
        let parsedCasksJson: [BrewPackage.PackageCommandOutput.Casks] = try self.parseCasksJson(jsonAsData: allCasksJson)
        
        AppConstants.shared.logger.debug("Successfully parsed all Casks")
        
        let processedAvailableCasks: Set<AdoptableCaskComparable> = processParsedAvailableCasks(from: parsedCasksJson)
        
        AppConstants.shared.logger.debug("Successfully processed available Casks")
        
        let installedApps: Set<String> = try self.getInstalledApps()
        
        let processedAdoptableCasks: Set<AdoptableCaskComparable> = getAdoptableAppsFromAvailableCasks(
            installedApps: installedApps,
            allAvailableCasks: processedAvailableCasks
        )
        
        return processedAdoptableCasks
    }

    /// Download a JSON list of all available casks
    private func loadAllCasksJson() async throws(DataDownloadingError) -> Data
    {
        return try await downloadDataFromURL(.init(string: "https://formulae.brew.sh/api/cask.json")!)
    }

    enum CasksJsonParsingError: Error
    {
        case failedToParseJson(error: String)
    }
    
    /// Parse the downloaded Casks JSON into usable objects
    private func parseCasksJson(
        jsonAsData: Data
    ) throws(CasksJsonParsingError) -> [BrewPackage.PackageCommandOutput.Casks]
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
    
    /// A struct for holding a Cask's name and its executable
    struct AdoptableCaskComparable: Hashable
    {
        let caskName: String
        let caskExecutable: String
    }
    
    /// Take the array that contains all Casks, and transform them into a list of Cask names, associated with their executable names for comparing with the contents of the Applications folder
    private func processParsedAvailableCasks(
        from parsedCasks: [BrewPackage.PackageCommandOutput.Casks]
    ) -> Set<AdoptableCaskComparable>
    {
        var resultArray: Set<AdoptableCaskComparable> = .init()
        
        for parsedCask in parsedCasks
        {
            if let executableName = parsedCask.executableName
            {
                AppConstants.shared.logger.debug("Processed potential adoptable cask: \(parsedCask.token) - \(executableName)")
                
                resultArray.insert(
                    .init(
                        caskName: parsedCask.token,
                        caskExecutable: executableName
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
    private func getInstalledApps() throws(AppDirectoryReadingError) -> Set<String>
    {
        do
        {
            let contentsOfApplicationsFolder: [URL] = try FileManager.default.contentsOfDirectory(at: .applicationDirectory, includingPropertiesForKeys: [.isExecutableKey], options: .skipsHiddenFiles)
            
            return Set(contentsOfApplicationsFolder.map({ $0.lastPathComponent }))
        }
        catch let applicationDirectoryReadingError
        {
            AppConstants.shared.logger.error("Failed to get contents of Applications directory: \(applicationDirectoryReadingError)")
            
            throw .generic(error: applicationDirectoryReadingError.localizedDescription)
        }
    }
    
    /// Compare the contents of the Applications folder with the available casks, and also remove installed casks using the Cask tracker
    private func getAdoptableAppsFromAvailableCasks(
        installedApps: Set<String>,
        allAvailableCasks: Set<AdoptableCaskComparable>
    ) -> Set<AdoptableCaskComparable>
    {
        /// Filter out those available Casks whose executables match those in the Applications folder
        let caskNamesOfAppsNotInstalledThroughHomebrew: Set<AdoptableCaskComparable> = allAvailableCasks.filter { adoptableCask in
            installedApps.contains(adoptableCask.caskExecutable)
        }
        
        /// Only get the names of installed packages to make the comparing faster
        let installedCaskNames: Set<String> = .init(successfullyLoadedCasks.map({ $0.name }))
        
        let caskNamesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCaskTracker: Set<AdoptableCaskComparable> = caskNamesOfAppsNotInstalledThroughHomebrew.filter { !installedCaskNames.contains($0.caskName) }
        
        print("Finally processed casks: \(caskNamesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCaskTracker)")
        
        return caskNamesOfAppsNotInstalledThroughHomebrewThatAreAlsoNotInTheCaskTracker
    }
}
