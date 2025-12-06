//
//  Notifications Settings.swift
//  Cork
//
//  Created by David Bureš - P on 14.05.2025.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    /// Whether notifications are enabled
    static let areNotificationsEnabled: Key<Bool> = .init("areNotificationsEnabled", default: true)
    
    /// Type of notifications for outdated packages
    /// Types:
    /// - ``OutdatedPackageNotificationType.badge``: Only a badge in the app's icon
    /// - ``OutdatedPackageNotificationType.both``: Badge, as well as a notification
    static let outdatedPackageNotificationType: Key<OutdatedPackageNotificationType> = .init("outdatedPackageNotificationType", default: .badge)
    
    /// Whether to send a notification about the results of a package updating action
    static let notifyAboutPackageUpgradeResults: Key<Bool> = .init("notifyAboutPackageUpgradeResults", default: false)
    
    /// Whether no send a notification about the results of a package installation action
    static let notifyAboutPackageInstallationResults: Key<Bool> = .init("notifyAboutPackageInstallationResults", default: false)
    
    /// Whether to send a notificaiton about results of mass package adoption
    static let notifyAboutMassAdoptionResults: Key<Bool> = .init("notifyAboutMassAdoptionResults", default: false)
}
