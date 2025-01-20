//
//  Export Brewfile.swift
//  Cork
//
//  Created by David Bureš on 10.11.2023.
//

import Foundation
import CorkShared

enum BrewfileDumpingError: LocalizedError
{
    case couldNotDetermineWorkingDirectory, errorWhileDumpingBrewfile(error: String), couldNotReadBrewfile

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotDetermineWorkingDirectory:
            return String(localized: "error.brewfile.export.could-not-determine-working-directory")
        case .errorWhileDumpingBrewfile(let error):
            return String(localized: "error.brewfile.export.could-not-dump-with-error.\(error)")
        case .couldNotReadBrewfile:
            return String(localized: "error.brewfile.export.could-not-read-temporary-brewfile")
        }
    }
}

/// Exports the Brewfile and returns the contents of the Brewfile itself for further manipulation. Does not preserve the Brewfile
@MainActor
func exportBrewfile(appState: AppState) async throws -> String
{
    appState.showSheet(ofType: .brewfileExport)

    defer
    {
        appState.dismissSheet()
    }

    let brewfileParentLocation: URL = URL.temporaryDirectory

    let pathRawOutput: TerminalOutput = await shell(URL(string: "/bin/pwd")!, ["-L"])

    let brewfileDumpingResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["bundle", "-f", "dump"], workingDirectory: brewfileParentLocation)

    /// Throw an error if the working directory could not be determined
    if !pathRawOutput.standardError.isEmpty
    {
        throw BrewfileDumpingError.couldNotDetermineWorkingDirectory
    }

    /// Throw an error if the working directory is so fucked up it's unusable
    guard let workingDirectory = URL(string: pathRawOutput.standardOutput.replacingOccurrences(of: "\n", with: ""))
    else
    {
        throw BrewfileDumpingError.couldNotDetermineWorkingDirectory
    }

    if brewfileDumpingResult.standardError.contains("(E|e)rror")
    {
        throw BrewfileDumpingError.errorWhileDumpingBrewfile(error: brewfileDumpingResult.standardError)
    }

    AppConstants.shared.logger.info("Path: \(workingDirectory, privacy: .auto)")

    print("Brewfile dumping result: \(brewfileDumpingResult)")

    let brewfileLocation: URL = brewfileParentLocation.appendingPathComponent("Brewfile", conformingTo: .fileURL)

    do
    {
        let brewfileContents: String = try String(contentsOf: brewfileLocation)

        /// Delete the brewfile
        try? FileManager.default.removeItem(at: brewfileLocation)

        return brewfileContents
    }
    catch let brewfileReadingError
    {
        AppConstants.shared.logger.error("Error while reading contents of Brewfile: \(brewfileReadingError, privacy: .public)")
        throw BrewfileDumpingError.couldNotReadBrewfile
    }
}
