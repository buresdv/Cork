//
//  Notifications Pane.swift
//  Cork
//
//  Created by David Bureš on 13.08.2023.
//

import SwiftUI

struct NotificationsPane: View
{
    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                Picker(selection: $outdatedPackageNotificationType) {
                   Text("settings.notifications.outdated-package-notification-type.badge")
                        .tag(OutdatedPackageNotificationType.badge)
                    
                    Text("settings.notifications.outdated-package-notification-type.notification")
                        .tag(OutdatedPackageNotificationType.notification)
                    
                    Text("settings.notifications.outdated-package-notification-type.none")
                        .tag(OutdatedPackageNotificationType.none)
                } label: {
                    Text("settings.notifications.outdated-package-notification-type")
                }

            }
        }
    }
}
