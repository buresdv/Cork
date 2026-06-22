//
//  Package Installation Steps.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import CorkShared
import CorkModels
import CorkTerminalFunctions

enum PackageInstallationProcessSteps: Equatable
{
    enum UnexpectedTerminalOutputType: Equatable
    {
        /// The unexpected outputs did NOT contain any STDERR outputs
        case containedErrors(rawOutput: [TerminalOutput])
        
        /// The unexpected outputs DID contain some STDERR outputs
        case didNotContainErrors(rawOutput: [TerminalOutput])
    }
    
    case ready
    case searching(
        forSearchString: String
    )
    case presentingSearchResults(
        forSearchString: String,
        foundFormulae: [MinimalHomebrewPackage],
        foundCasks: [MinimalHomebrewPackage]
    )
    case installing(
        package: MinimalHomebrewPackage
    )
    case finished
    case unexpectedTerminalOutput(UnexpectedTerminalOutputType)
    case erroredOut(
        package: MinimalHomebrewPackage,
        withError: InstallationProgressTracker.InstallationError.ImplementedError
    )
    
    var isDismissable: Bool
    {
        switch self {
        case .ready:
            true
        case .searching:
            false
        case .presentingSearchResults:
            true
        case .installing:
            false
        case .finished:
            true
        case .unexpectedTerminalOutput:
            true
        case .erroredOut:
            true
        }
    }
}
