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
    case updating(type: UpdatePackagesView.UpdateType)
    case finished
    case erroredOut(results: [OutdatedPackagesTracker.IndividualPackageUpdatingError])
    case noUpdatesAvailable
}
