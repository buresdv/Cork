//
//  Package Install Initialization Error.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import Foundation

enum PackageInstallationInitializationError: Error
{
    case couldNotStartInstallProcessWithPackage(package: BrewPackage?)
}
