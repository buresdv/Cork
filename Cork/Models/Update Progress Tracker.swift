//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@Observable
class UpdateProgressTracker
{
    var updateProgress: Float = 0
    var errors: [String] = .init()

    var realTimeOutput: [RealTimeTerminalLine] = .init()

    enum UpdateProcessStages: LocalizedStringKey, CustomStringConvertible, TerminalOutputMatchable
    {
        case downloading = "update-packages.detail-stage.downloading"
        case pouring = "update-packages.detail-stage.pouring"
        case cleanup = "update-packages.detail-stage.cleanup"
        case backingUp = "update-packages.detail-stage.backing-up"
        case linking = "update-packages.detail-stage.linking"

        var description: String
        {
            switch self
            {
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

        var matchForStandardOutputs: [String]
        {
            switch self
            {
            case .downloading:
                ["Downloading"]
            case .pouring:
                ["Pouring"]
            case .cleanup:
                ["cleanup"]
            case .backingUp:
                ["Backing App"]
            case .linking:
                ["Moving App", "Linking", ""]
            }
        }

        var matchForStandardErrors: [String]
        {
            switch self
            {
            case .downloading:
                <#code#>
            case .pouring:
                <#code#>
            case .cleanup:
                <#code#>
            case .backingUp:
                <#code#>
            case .linking:
                <#code#>
            }
        }
    }
}
