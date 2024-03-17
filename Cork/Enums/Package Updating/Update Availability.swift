//
//  Update Availability.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation

enum PackageUpdateAvailability: CustomStringConvertible
{
    case updatesAvailable, noUpdatesAvailable

    var description: String
    {
        switch self
        {
        case .updatesAvailable: return "Updates available"
        case .noUpdatesAvailable: return "No updates available"
        }
    }
}
