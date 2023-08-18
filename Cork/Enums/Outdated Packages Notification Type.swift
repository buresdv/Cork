//
//  Outdated Packages Notification Type.swift
//  Cork
//
//  Created by David Bureš on 13.08.2023.
//

import Foundation

enum OutdatedPackageNotificationType: String, Codable, CaseIterable
{
    case none, badge, notification, both
}
