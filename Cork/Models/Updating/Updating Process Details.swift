//
//  Updating Process Details.swift
//  Cork
//
//  Created by David Bureš on 02.09.2023.
//

import Foundation
import SwiftUI

enum UpdateProcessStages: LocalizedStringKey, CustomStringConvertible
{
    case downloading = "update-packages.detail-stage.downloading"
    case pouring = "update-packages.detail-stage.pouring"
    case cleanup = "update-packages.detail-stage.cleanup"
    case backingUp = "update-packages.detail-stage.backing-up"
    case linking = "update-packages.detail-stage.linking"
    
    var description: String
    {
        switch self {
            case .downloading:
                return "Downloading"
            case .pouring:
                return "Pouring"
            case .cleanup:
                return "Cleanup"
            case .backingUp:
                return "Backing Up"
            case .linking:
                return "Linkling"
        }
    }
}

class UpdatingProcessDetails: ObservableObject
{
    @Published var currentStage: UpdateProcessStages = .backingUp
}
