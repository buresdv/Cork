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
                        print("Will re-check notification authorization status")
                        await appState.requestNotificationAuthorization()
                        
                        switch appState.notificationStatus?.authorizationStatus {
                            case .notDetermined:
                                print("Not determined")
                            case .denied:
                                print("Denied")
                            case .authorized:
                                print("Authorized")
                            case .provisional:
                                print("Provisional")
                            case .ephemeral:
                                print("Ephemeral")
                            case nil:
                                print("Nil")
                        }
                        
                        if appState.notificationStatus?.authorizationStatus == .denied
                        {
                            areNotificationsEnabled = false
                        }
                    }
                    .onChange(of: areNotificationsEnabled, perform: { newValue in
                        Task(priority: .background) {
                            let notificationsEnabledInSystemSettings: Bool = await appState.requestNotificationAuthorization()
                            if notificationsEnabledInSystemSettings
                            {
                                await appState.requestNotificationAuthorization()
                                if appState.notificationStatus?.authorizationStatus == .denied
                                {
                                    areNotificationsEnabled = false
                                }
                            }
                        }
                    })
                    .disabled(appState.notificationStatus?.authorizationStatus == .denied)
                    
                    if appState.notificationStatus?.authorizationStatus == .denied 
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
                    
                    LabeledContent {
                        Toggle(isOn: $notifyAboutPackageUpgradeResults, label: {
                            Text("settings.notifications.notify-about-upgrade-result")
                        })
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
