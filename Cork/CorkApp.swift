//
//  CorkApp.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

@main
struct CorkApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var brewData = BrewDataStorage()
    @StateObject var availableTaps = AvailableTaps()
    
    @StateObject var topPackagesTracker = TopPackagesTracker()

    @StateObject var updateProgressTracker = UpdateProgressTracker()
    @StateObject var outdatedPackageTracker = OutdatedPackageTracker()

    @StateObject var selectedPackageInfo = SelectedPackageInfo()
    @StateObject var selectedTapInfo = SelectedTapInfo()

    @Environment(\.openWindow) private var openWindow
    @AppStorage("showInMenuBar") var showInMenuBar = false

    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge

    var body: some Scene
    {
        Window("Main Window", id: "main")
        {
            ContentView()
                .environmentObject(appDelegate.appState)
                .environmentObject(brewData)
                .environmentObject(availableTaps)
                .environmentObject(selectedPackageInfo)
                .environmentObject(selectedTapInfo)
                .environmentObject(updateProgressTracker)
                .environmentObject(outdatedPackageTracker)
                .environmentObject(topPackagesTracker)
                .task
                {
                    NSWindow.allowsAutomaticWindowTabbing = false

                    if areNotificationsEnabled
                    {
                        await appDelegate.appState.setupNotifications()
                    }
                }
                .onChange(of: outdatedPackageTracker.outdatedPackages)
                { newValue in
                    let outdatedPackageCount = newValue.count

                    if outdatedPackageCount != 0
                    {
                        if areNotificationsEnabled
                        {
                            if outdatedPackageNotificationType == .badge || outdatedPackageNotificationType == .both
                            {
                                NSApp.dockTile.badgeLabel = String(outdatedPackageCount)
                            }

                            if outdatedPackageNotificationType == .notification || outdatedPackageNotificationType == .both
                            {
                                print("Will try to send notification")
                                sendNotification(title: String(localized: "notification.outdated-packages-found.title"), subtitle: String.localizedPluralString("notification.outdated-packages-found.body", outdatedPackageCount))
                            }
                        }
                    }
                }
                .onChange(of: outdatedPackageNotificationType) // Set the correct app badge number when the user changes their notification settings
                { newValue in
                    setAppBadge(outdatedPackageNotificationType: newValue)
                }
                .onChange(of: areNotificationsEnabled)
                { newValue in // Remove the badge from the app icon if the user turns off notifications, put it back when they turn them back on
                    if newValue == false
                    {
                        NSApp.dockTile.badgeLabel = ""
                    }
                    else
                    {
                        setAppBadge(outdatedPackageNotificationType: outdatedPackageNotificationType)
                    }
                }
        }
        .commands
        {
            CommandGroup(replacing: .appInfo)
            {
                Button
                {
                    appDelegate.showAboutPanel()
                } label: {
                    Text("navigation.about")
                }
            }
            CommandGroup(before: .help) // The "Report Bugs" section
            {
                Menu
                {
                    Button
                    {
                        NSWorkspace.shared.open(URL(string: "https://github.com/buresdv/Cork/issues/new")!)
                    } label: {
                        Text("action.report-bugs.git-hub")
                    }

                    Button
                    {
                        let emailSubject: String = "Cork Error Report: v\(NSApplication.appVersion!)-\(NSApplication.buildVersion!)"
                        let emailBody: String = "This is what went wrong:\n\nThis is what I expected to happen:\n\nDid Cork crash?"

                        let emailService = NSSharingService(named: NSSharingService.Name.composeEmail)
                        emailService?.recipients = ["vsedni_zelenina.0y@icloud.com"]
                        emailService?.subject = emailSubject
                        emailService?.perform(withItems: [emailBody])

                    } label: {
                        Text("action.report-bugs.email")
                    }

                } label: {
                    Text("action.report-bugs.menu-category")
                }

                Divider()
            }

            SidebarCommands()
            CommandGroup(replacing: .newItem) // Disables "New Window"
            {}

            CommandMenu("navigation.menu.packages")
            {
                Button
                {
                    appDelegate.appState.isShowingInstallationSheet.toggle()
                } label: {
                    Text("navigation.menu.packages.install")
                }
                .keyboardShortcut("n")

                Button
                {
                    appDelegate.appState.isShowingAddTapSheet.toggle()
                } label: {
                    Text("navigation.menu.packages.add-tap")
                }
                .keyboardShortcut("n", modifiers: [.command, .option])

                Divider()

                Button
                {
                    appDelegate.appState.isShowingUpdateSheet = true
                } label: {
                    Text("navigation.menu.packages.update")
                }
                .keyboardShortcut("r")

                /* Divider()

                 Button {
                     print("Will uninstall packages")
                 } label: {
                     Text("Uninstall Package")
                 }
                  */
            }

            CommandMenu("navigation.menu.maintenance")
            {
                Button
                {
                    appDelegate.appState.isShowingMaintenanceSheet.toggle()
                } label: {
                    Text("navigation.menu.maintenance.perform")
                }
                .keyboardShortcut("m", modifiers: [.command, .shift])

                if appDelegate.appState.cachedDownloadsFolderSize != 0
                {
                    Button
                    {
                        appDelegate.appState.isShowingFastCacheDeletionMaintenanceView.toggle()
                    } label: {
                        Text("navigation.menu.maintenance.delete-cached-downloads")
                    }
                    .keyboardShortcut("m", modifiers: [.command, .option])
                }
            }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)

        Settings
        {
            SettingsView()
                .environmentObject(appDelegate.appState)
        }

        let outdatedCountString = String.localizedPluralString("start-page.updates.count", outdatedPackageTracker.outdatedPackages.count)
        MenuBarExtra(outdatedCountString, systemImage: outdatedPackageTracker.outdatedPackages.count == 0 ? "mug" : "mug.fill", isInserted: $showInMenuBar)
        {
            Text(outdatedCountString)
            if outdatedPackageTracker.outdatedPackages.count > 0
            {
                Button("navigation.upgrade-packages")
                {
                    switchCorkToForeground()
                    appDelegate.appState.isShowingUpdateSheet = true
                }
            }
            Button("navigation.install-package")
            {
                switchCorkToForeground()
                appDelegate.appState.isShowingInstallationSheet.toggle()
            }
            Divider()
            Button("menubar.open.cork")
            {
                openWindow(id: "main")

                switchCorkToForeground()
            }
        }
    }

    func switchCorkToForeground()
    {
        if #available(macOS 14.0, *)
        {
            NSApp.activate(ignoringOtherApps: true)
        }
        else
        {
            let runningApps: [NSRunningApplication] = NSWorkspace.shared.runningApplications

            for app in runningApps
            {
                if app.localizedName == "Cork"
                {
                    if !app.isActive
                    {
                        app.activate(options: .activateIgnoringOtherApps)
                    }
                }
            }
        }
    }

    func setAppBadge(outdatedPackageNotificationType: OutdatedPackageNotificationType)
    {
        if outdatedPackageNotificationType == .badge || outdatedPackageNotificationType == .both
        {
            NSApp.dockTile.badgeLabel = String(outdatedPackageTracker.outdatedPackages.count)
        }
        else if outdatedPackageNotificationType == .notification || outdatedPackageNotificationType == .none
        {
            NSApp.dockTile.badgeLabel = ""
        }
    }
}
