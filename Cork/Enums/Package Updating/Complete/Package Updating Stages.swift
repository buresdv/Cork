//
//  Package Updating Stages.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import CorkModels

enum PackageUpdatingStage
{
    case updating
    case finished
    case erroredOut(results: (erroredOutPackage: OutdatedPackage, error: OutdatedPackagesTracker.IndividualPackageUpdatingError))
    case noUpdatesAvailable
}
