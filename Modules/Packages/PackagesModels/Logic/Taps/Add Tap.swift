//
//  Add Tap.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

public enum TappingError: LocalizedError, Equatable
{
    public enum ImplementedError: Sendable
    {
        case repositoryNotFound
        // case tapAlreadyAdded
        
        public var errorDescription: String?
        {
            switch self
            {
            case .repositoryNotFound:
                return String(localized: "add-tap.error.repository-not-found.description")
                
            // case .tapAlreadyAdded:
                // return String(localized: "add-tap.error.already-added")
            }
        }
    }
    
    case implemented(ImplementedError)
    case unimplemented(rawOutput: [TerminalOutput])
}

public extension TapTracker
{
    func addTap(tap: BrewTap, forcedRepoAddress: URL? = nil) async throws(TappingError)
    {
        let tappingOutputs: [TerminalOutput]
        
        if let forcedRepoAddress, !forcedRepoAddress.pathComponents.contains("github")
        {
            appConstants.logger.info("Will use forced URL: \(forcedRepoAddress.absoluteString, privacy: .public)")
            
            tappingOutputs = await shell(AppConstants.shared.brewExecutablePath, ["tap", tap.name(withPrecision: .full), forcedRepoAddress.absoluteString])
        }
        else
        {
            appConstants.logger.info("Will not use a forced URL")
            
            tappingOutputs = await shell(AppConstants.shared.brewExecutablePath, ["tap", tap.name(withPrecision: .full)])
        }
        

        AppConstants.shared.logger.debug("Tapping result: \(tappingOutputs, privacy: .public)")
        
        if tappingOutputs.containsErrors
        {
            // If the outputs are empty, it means the tap is already added. No need to do anything
            if !tappingOutputs.isEmpty
            {
                if tappingOutputs.contains("Repository not found", in: .standardErrors)
                {
                    throw .implemented(.repositoryNotFound)
                }
                else if tappingOutputs.contains("could not read Username", in: .standardErrors)
                {
                    throw .implemented(.repositoryNotFound)
                }
                else
                {
                    throw .unimplemented(rawOutput: tappingOutputs)
                }
            }
        }
        else
        {
            self.addedTaps.insert(.success(tap))
        }
    }

}
