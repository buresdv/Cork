//
//  Package Installation Steps.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

enum PackageInstallationProcessSteps
{
    case ready, searching, presentingSearchResults, installing, finished, fatalError, requiresSudoPassword, wrongArchitecture, anotherProcessAlreadyRunning
}
