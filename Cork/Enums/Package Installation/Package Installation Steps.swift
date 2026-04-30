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
    case ready
    case searching(forSearchString: String)
    case presentingSearchResults(
        forSearchString: String,
        foundFormulae: [MinimalHomebrewPackage],
        foundCasks: [MinimalHomebrewPackage]
    )
    case installing(package: MinimalHomebrewPackage)
    case finished
    case unexpectedTerminalOutput(rawOutput: [TerminalOutput])
    case erroredOut(withError: InstallationProgressTracker.InstallationError)
    
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
