//
//  Package Updating Stages.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation

enum PackageUpdatingStage
{
    case updating, finished, erroredOut(packagesRequireSudo: Bool), noUpdatesAvailable
}
