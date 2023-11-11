//
//  Import Brewfile.swift
//  Cork
//
//  Created by David Bureš on 10.11.2023.
//

import Foundation

enum BrewfileReadingError: Error
{
    case couldNotGetBrewfileLocation, couldNotImportFile
}

@MainActor
func importBrewfile(from url: URL, appState: AppState, brewData: BrewDataStorage) async throws
{
    appState.isShowingBrewfileImportProgress = true
    
    appState.brewfileImportingStage = .importing
    
    print(url.path)
    
    let brewfileImportingResultRaw: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["bundle", "--file", url.path, "--no-lock"])
    
    print(brewfileImportingResultRaw)
    
    if !brewfileImportingResultRaw.standardError.isEmpty
    {
        throw BrewfileReadingError.couldNotImportFile
    }
    
    appState.brewfileImportingStage = .finished
    
    await synchronizeInstalledPackages(brewData: brewData)
}
