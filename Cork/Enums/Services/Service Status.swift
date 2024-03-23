//
//  Service Status.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

/// Statuses taken from here: https://github.com/Homebrew/homebrew-services/blob/89ba81ef193cb4d623b0b1385bdefa4460f1e97a/lib/service/commands/list.rb#L70

import Foundation
import SwiftUI

enum ServiceStatus: Codable, Hashable, CustomStringConvertible
{
    case started
    case scheduled

    case error
    case unknown

    case stopped
    case none

    case other

    init(_ rawValue: String)
    { /// This will take the `String` representation from the JSON and return the proper `ServiceStatus` type
        switch rawValue
        {
        case "started":
            self = .started
        case "scheduled":
            self = .scheduled
        case "error":
            self = .error
        case "stopped":
            self = .stopped
        case "none":
            self = .none
        default:
            self = .other
        }
    }

    var description: String
    {
        switch self
        {
        case .started:
            return "services.status.started"
        case .scheduled:
            return "services.status.scheduled"
        case .error:
            return "services.status.error"
        case .unknown:
            return "services.status.unknown"
        case .stopped:
            return "services.status.stopped"
        case .none:
            return "services.status.none"
        case .other:
            return "services.status.other"
        }
    }
    
    var displayableName: LocalizedStringKey
    {
        switch self
        {
            case .started:
                return "services.status.started"
            case .scheduled:
                return "services.status.scheduled"
            case .error:
                return "services.status.error"
            case .unknown:
                return "services.status.unknown"
            case .stopped:
                return "services.status.stopped"
            case .none:
                return "services.status.none"
            case .other:
                return "services.status.other"
        }
    }
}
