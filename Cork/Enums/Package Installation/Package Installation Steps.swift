//
//  Package Installation Steps.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import CorkShared
import CorkModels
import SwiftUI
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
            true
        case .finished:
            true
        case .unexpectedTerminalOutput:
            true
        case .erroredOut:
            true
        }
    }
    
    var customDismissButtonText: LocalizedStringKey?
    {
        switch self
        {
        case .ready:
            return nil
        case .searching(_):
            return nil
        case .presentingSearchResults(let forSearchString, let foundFormulae, let foundCasks):
            return nil
        case .installing(let package):
            return nil
        case .finished:
            return "action.close"
        case .unexpectedTerminalOutput(let unexpectedTerminalOutputType):
            return "action.close"
        case .erroredOut(let package, let withError):
            return "action.close"
        }
    }
}
