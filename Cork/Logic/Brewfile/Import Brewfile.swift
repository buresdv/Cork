//
//  Import Brewfile.swift
//  Cork
//
//  Created by David Bureš on 10.11.2023.
//

import Foundation
import CorkShared
import CorkModels
import CorkTerminalFunctions

enum BrewfileReadingError: LocalizedError
{
    case couldNotGetBrewfileLocation, couldNotImportFile(formattedPath: String)

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotGetBrewfileLocation:
            return String(localized: "error.brewfile.importing.could-not-get-selected-brewfile-location")
        case .couldNotImportFile(let formattedPath):
            return String(localized: "error.brewfile.importing.could-not-import.\(formattedPath)")
        }
    }
}

@MainActor
func importBrewfile(from url: URL, appState: AppState, brewPackagesTracker: BrewPackagesTracker, cachedDownloadsTracker: CachedDownloadsTracker) async throws
{
    appState.showSheet(ofType: .brewfileImport)

    appState.brewfileImportingStage = .importing

    AppConstants.shared.logger.info("Brewfile import path: \(url.path)")

    let brewfileImportingResultRaw: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["bundle", "--file", url.path, "--no-lock"])

    AppConstants.shared.logger.info("Brewfile import result:\nStandard output: \(brewfileImportingResultRaw.standardOutput, privacy: .public)\nStandard error: \(brewfileImportingResultRaw.standardError)")

    if !brewfileImportingResultRaw.standardError.isEmpty
    {
        throw BrewfileReadingError.couldNotImportFile(formattedPath: url.absoluteString)
    }

    appState.brewfileImportingStage = .finished

    do
    {
        try await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
    }
    catch let synchronizationError
    {
        appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: synchronizationError.localizedDescription))
    }
}
