//
//  Outdated Packages Notification Type.swift
//  Cork
//
//  Created by David Bureš on 13.08.2023.
//

import Foundation
import Defaults

public enum OutdatedPackageNotificationType: String, Codable, CaseIterable, Defaults.Serializable
{
    case none, badge, notification, both
}
