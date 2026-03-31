//
//  Export Brewfile.swift
//  Cork
//
//  Created by David Bureš on 10.11.2023.
//

import Foundation
import CorkShared
import CorkModels
import CorkTerminalFunctions

public extension BrewfileManager
{
    enum BrewfileDumpingError: LocalizedError
    {
        case couldNotDetermineWorkingDirectory
        case errorWhileDumpingBrewfile(errors: [String])
        case couldNotReadBrewfile(error: String)

        public var errorDescription: String?
        {
            switch self
            {
            case .couldNotDetermineWorkingDirectory:
                return String(localized: "error.brewfile.export.could-not-determine-working-directory")
            case .errorWhileDumpingBrewfile:
                return String(localized: "error.brewfile.export.could-not-dump-with-error")
            case .couldNotReadBrewfile(let error):
                return error
            }
        }
    }

    /// Exports the Brewfile and returns the contents of the Brewfile itself for further manipulation. Does not preserve the Brewfile
    @MainActor
    func exportBrewfile() async throws(BrewfileDumpingError) -> BrewbakFile
    {
        let brewfileParentLocation: URL = URL.temporaryDirectory.resolvingSymlinksInPath()
        
        let finalBrewfileLocation: URL = brewfileParentLocation.appendingPathComponent("Brewfile", conformingTo: .fileURL)
        
        AppConstants.shared.logger.info("Brewfile parent location: \(brewfileParentLocation)")
        
        let brewfileDumpingResult: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["bundle", "dump", "--file", finalBrewfileLocation.path])

        guard !brewfileDumpingResult.contains("Error", in: .standardErrors, .standardOutputs) else
        {
            AppConstants.shared.logger.error("There was an error in the dumping result")
            
            throw BrewfileDumpingError.errorWhileDumpingBrewfile(errors: brewfileDumpingResult.standardErrors)
        }

        print("Brewfile dumping result: \(brewfileDumpingResult)")

        let doesBrewfileExist: Bool = FileManager.default.fileExists(atPath: finalBrewfileLocation.path())
        
        AppConstants.shared.logger.info("Does brewfile exist an expected location? \(doesBrewfileExist)")
        
        do
        {
            let brewfileContents: String = try String(contentsOf: finalBrewfileLocation)

            /// Delete the brewfile
            do
            {
                try FileManager.default.removeItem(at: finalBrewfileLocation)
            } catch let tempBrewfileDeletionError {
                AppConstants.shared.logger.error("Fialed while deleting old brewfile: \(tempBrewfileDeletionError)")
            }

            return .init(text: brewfileContents)
        }
        catch let brewfileReadingError
        {
            AppConstants.shared.logger.error("Error while reading contents of Brewfile: \(brewfileReadingError, privacy: .public)")
            throw BrewfileDumpingError.couldNotReadBrewfile(error: brewfileReadingError.localizedDescription)
        }
    }

}
