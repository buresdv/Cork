//
//  Notifications Pane.swift
//  Cork
//
//  Created by David Bureš on 13.08.2023.
//

import SwiftUI
import UserNotifications

struct NotificationsPane: View
{
    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge
    
    @AppStorage("notifyAboutPackageUpgradeResults") var notifyAboutPackageUpgradeResults: Bool = false
    @AppStorage("notifyAboutPackageInstallationResults") var notifyAboutPackageInstallationResults: Bool = false
    
    @EnvironmentObject var appState: AppState
    
    @State private var isShowingNotificationHelpPopup: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            VStack(alignment: .center, spacing: 10)
            {
                VStack(alignment: .center, spacing: 5)
                {
                    Toggle(isOn: $areNotificationsEnabled, label: {
                        Text("settings.notifications.enable-notifications")
                    })
                    .toggleStyle(.switch)
                    .task
                    {
                        AppConstants.logger.debug("Will re-check notification authorization status")
                        await appState.requestNotificationAuthorization()
                        
                        switch appState.notificationAuthStatus {
                            case .notDetermined:
                                AppConstants.logger.info("Not determined")
                            case .denied:
                                AppConstants.logger.info("Denied")
                            case .authorized:
                                AppConstants.logger.info("Authorized")
                            case .provisional:
                                AppConstants.logger.info("Provisional")
                            case .ephemeral:
                                AppConstants.logger.info("Ephemeral")
                            default:
                                AppConstants.logger.info("TF")
                        }
                        
                        if appState.notificationAuthStatus == .denied
                        {
                            areNotificationsEnabled = false
                        }
                    }
                    .disabled(appState.notificationAuthStatus == .denied)
                    
                    if appState.notificationAuthStatus == .denied
                    {
                        Text("settings.notifications.notifications-disabled-in-settings.tooltip")
                            .font(.caption)
                            .foregroundColor(Color(nsColor: NSColor.systemGray))
                    }
                }
                
                Divider()
                
                Form
                {
                    Picker(selection: $outdatedPackageNotificationType) {
                        Text("settings.notifications.outdated-package-notification-type.badge")
                            .tag(OutdatedPackageNotificationType.badge)
                        
                        Text("settings.notifications.outdated-package-notification-type.notification")
                            .tag(OutdatedPackageNotificationType.notification)
                        
                        Text("settings.notifications.outdated-package-notification-type.both")
                            .tag(OutdatedPackageNotificationType.both)
                        
                        Divider()
                        
                        Text("settings.notifications.outdated-package-notification-type.none")
                            .tag(OutdatedPackageNotificationType.none)
                    } label: {
                        Text("settings.notifications.outdated-package-notification-type")
                    }
                    
                    LabeledContent
                    {
                        VStack(alignment: .leading)
                        {
                            Toggle(isOn: $notifyAboutPackageUpgradeResults, label: {
                                Text("settings.notifications.notify-about-upgrade-result")
                            })
                            Toggle(isOn: $notifyAboutPackageInstallationResults, label: {
                                Text("settings.notifications.notify-about-installation-result")
                            })
                        }
                    } label: {
                        Text("settings.notifications.notify-about-various-actions")
                    }

                }
                .disabled(!areNotificationsEnabled)
                
                HStack(alignment: .center)
                {
                    Spacer()
                    
                    HelpButton {
                        isShowingNotificationHelpPopup.toggle()
                    }
                    .popover(isPresented: $isShowingNotificationHelpPopup)
                    {
                        Text("settings.notifications.explanation")
                            .padding()
                    }
                }
            }
        }
    }
}
