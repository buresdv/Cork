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
    func addTap(name: String, forcedRepoAddress: URL? = nil) async throws(TappingError)
    {
        let tappingOutputs: [TerminalOutput]
        
        if let forcedRepoAddress
        {
            tappingOutputs = await shell(AppConstants.shared.brewExecutablePath, ["tap", name, forcedRepoAddress.absoluteString])
        }
        else
        {
            tappingOutputs = await shell(AppConstants.shared.brewExecutablePath, ["tap", name])
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
                else
                {
                    throw .unimplemented(rawOutput: tappingOutputs)
                }
            }
        }
        else
        {
            do
            {
                self.addedTaps.insert(.success(try .init(externalRepo: forcedRepoAddress, name: name)))
            }
            catch let intoTrackerAdditionError
            {
                AppConstants.shared.logger.error("Failed while adding tap to tracker: \(intoTrackerAdditionError)")
            }
        }
    }

}
