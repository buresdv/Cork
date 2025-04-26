//
//  Package Installation Steps.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

enum PackageInstallationProcessSteps: Equatable
{
    case ready
    case searching
    case presentingSearchResults
    case installing(packageToInstall: BrewPackage)
    case finished
    case fatalError(packageThatWasGettingInstalled: BrewPackage)
    case requiresSudoPassword(packageThatWasGettingInstalled: BrewPackage)
    case wrongArchitecture(packageThatWasGettingInstalled: BrewPackage)
    case binaryAlreadyExists(packageThatWasGettingInstalled: BrewPackage)
    case anotherProcessAlreadyRunning
    case installationTerminatedUnexpectedly
}
