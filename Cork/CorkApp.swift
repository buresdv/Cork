//
//  CorkApp.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//


import SwiftUI
import UserNotifications

@main
struct CorkApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var brewData = BrewDataStorage()
    @StateObject var availableTaps = AvailableTaps()

    @StateObject var topPackagesTracker = TopPackagesTracker()

    @StateObject var updateProgressTracker = UpdateProgressTracker()
    @StateObject var outdatedPackageTracker = OutdatedPackageTracker()

    @Environment(\.openWindow) private var openWindow
    @AppStorage("showInMenuBar") var showInMenuBar = false

    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge

    @State private var sendStandardUpdatesAvailableNotification: Bool = true

    @State private var isUninstallingOrphanedPackages: Bool = false
    @State private var isPurgingHomebrewCache: Bool = false
    @State private var isDeletingCachedDownloads: Bool = false

    let backgroundUpdateTimer: NSBackgroundActivityScheduler = {
        let scheduler = NSBackgroundActivityScheduler(identifier: "com.davidbures.Cork.backgroundAutoUpdate")
        scheduler.repeats = true
        scheduler.interval = AppConstants.backgroundUpdateInterval
        scheduler.tolerance = AppConstants.backgroundUpdateIntervalTolerance
        scheduler.qualityOfService = .background

        return scheduler
    }()

    var body: some Scene
    {
        Window("Main Window", id: "main")
        {
            ContentView()
                .environmentObject(appDelegate.appState)
                .environmentObject(brewData)
                .environmentObject(availableTaps)
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
                .onAppear
                {
                    // Start the background update scheduler when the app starts
                    backgroundUpdateTimer.schedule
                    { (completion: NSBackgroundActivityScheduler.CompletionHandler) in
                        print("Scheduled event fired at \(Date())")

                        Task(priority: .background)
                        {
                            var updateResult = await shell(AppConstants.brewExecutablePath, ["update"])

                            print("Update result: \(updateResult)")

                            do
                            {
                                var newOutdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)

                                print("Outdated packages checker output: \(newOutdatedPackages)")

                                defer
                                {
                                    print("Will purge temporary update trackers")

                                    updateResult = .init(standardOutput: "", standardError: "")
                                    newOutdatedPackages = .init()
                                }

                                if newOutdatedPackages.count > outdatedPackageTracker.outdatedPackages.count
                                {
                                    print("New updates found")

                                    /// Set this to `true` so the normal notification doesn't get sent
                                    sendStandardUpdatesAvailableNotification = false

                                    let differentPackages = newOutdatedPackages.subtracting(outdatedPackageTracker.outdatedPackages)
                                    print("Changed packages: \(differentPackages)")

                                    sendNotification(title: String(localized: "notification.new-outdated-packages-found.title"), subtitle: differentPackages.map(\.package.name).formatted(.list(type: .and)))

                                    outdatedPackageTracker.outdatedPackages = newOutdatedPackages

                                    sendStandardUpdatesAvailableNotification = true
                                }
                                else
                                {
                                    print("No new updates found")
                                }
                            }
                            catch
                            {
                                print("Something got fucked up")
                            }
                        }

                        completion(NSBackgroundActivityScheduler.Result.finished)
                    }
                }
                .onChange(of: outdatedPackageTracker.outdatedPackages.count)
                { newValue in
                    let outdatedPackageCount = newValue

                    if outdatedPackageCount != 0
                    {
                        if areNotificationsEnabled
                        {
                            if outdatedPackageNotificationType == .badge || outdatedPackageNotificationType == .both
                            {
                                if outdatedPackageCount > 0
                                {
                                    NSApp.dockTile.badgeLabel = String(outdatedPackageCount)
                                }
                            }

                            if outdatedPackageNotificationType == .notification || outdatedPackageNotificationType == .both
                            {
                                print("Will try to send notification")

                                /// This needs to be checked because when the background update system finds an update, we don't want to send this normal notification.
                                /// Instead, we want to send a more succinct notification that includes only the new package
                                if sendStandardUpdatesAvailableNotification
                                {
                                    sendNotification(title: String(localized: "notification.outdated-packages-found.title"), subtitle: String(localized: "notification.outdated-packages-found.body-\(outdatedPackageCount)"))
                                }
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
                        NSWorkspace.shared.open(URL(string: "https://github.com/buresdv/Cork/issues/new?assignees=&labels=Bug&projects=&template=bug_report.md")!)
                    } label: {
                        Text("action.report-bugs.git-hub")
                    }

                    Button
                    {
                        let emailSubject: String = "Cork Error Report: v\(NSApplication.appVersion!)-\(NSApplication.buildVersion!)"
                        let emailBody: String = "This is what went wrong:\n\nThis is what I expected to happen:\n\nDid Cork crash?"

                        let emailService = NSSharingService(named: NSSharingService.Name.composeEmail)
                        emailService?.recipients = ["bug-reporting@corkmac.app"]
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

            CommandGroup(before: .sidebar)
            {
                Button
                {
                    appDelegate.appState.navigationSelection = nil
                } label: {
                    Text("action.go-to-status-page.menu-bar")
                }
                .disabled(appDelegate.appState.navigationSelection == nil)
                Divider()
            }

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
        MenuBarExtra("app-name", systemImage: outdatedPackageTracker.outdatedPackages.count == 0 ? "mug" : "mug.fill", isInserted: $showInMenuBar)
        {
            Text("menu-bar.state-overview-\(brewData.installedFormulae.count)-\(brewData.installedCasks.count)-\(availableTaps.addedTaps.count)")

            Divider()

            if outdatedPackageTracker.outdatedPackages.count > 0
            {
                Menu {
                    ForEach(outdatedPackageTracker.outdatedPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn!}))
                    { outdatedPackage in
                        SanitizedPackageName(packageName: outdatedPackage.package.name, shouldShowVersion: false)
                    }
                } label: {
                    Text("notification.outdated-packages-found.body-\(outdatedPackageTracker.outdatedPackages.count)")
                }

                Button("navigation.upgrade-packages")
                {
                    switchCorkToForeground()
                    appDelegate.appState.isShowingUpdateSheet = true
                }
            }
            else
            {
                Text("update-packages.no-updates.description")
            }

            Divider()

            Button("navigation.install-package")
            {
                switchCorkToForeground()
                appDelegate.appState.isShowingInstallationSheet.toggle()
            }

            Divider()

            if !isUninstallingOrphanedPackages
            {
                Button("maintenance.steps.packages.uninstall-orphans")
                {
                    Task(priority: .userInitiated)
                    {
                        print("Will delete orphans")

                        do
                        {
                            let orphanUninstallResult = try await uninstallOrphansUtility()

                            sendNotification(
                                title: String(localized: "maintenance.results.orphans-removed"),
                                body: String(localized: "maintenance.results.orphans-count-\(orphanUninstallResult)"),
                                sensitivity: .active
                            )
                        }
                        catch let orphanUninstallationError as OrphanRemovalError
                        {
                            print("Failed while uninstalling orphans: \(orphanUninstallationError)")

                            sendNotification(
                                title: String(localized: "maintenance.results.orphans.failure"),
                                body: String(localized: "maintenance.results.orphans.failure.details-\(orphanUninstallationError.localizedDescription)"),
                                sensitivity: .active
                            )
                        }

                        await synchronizeInstalledPackages(brewData: brewData)
                    }
                }
            }
            else
            {
                Text("maintenance.step.removing-orphans")
            }

            if !isPurgingHomebrewCache
            {
                Button("maintenance.steps.downloads.purge-cache")
                {
                    Task(priority: .userInitiated)
                    {
                        print("Will purge cache")

                        isPurgingHomebrewCache = true

                        defer
                        {
                            isPurgingHomebrewCache = false
                        }

                        do
                        {
                            let packagesHoldingBackCachePurge = try await purgeHomebrewCacheUtility()

                            if packagesHoldingBackCachePurge.isEmpty
                            {
                                sendNotification(
                                    title: String(localized: "maintenance.results.package-cache"),
                                    sensitivity: .active
                                )
                            }
                            else
                            {
                                sendNotification(
                                    title: String(localized: "maintenance.results.package-cache"),
                                    body: String(localized: "maintenance.results.package-cache.skipped-\(packagesHoldingBackCachePurge.formatted(.list(type: .and)))"),
                                    sensitivity: .active
                                )
                            }
                        }
                        catch let cachePurgingError
                        {
                            print("There were errors while purging Homebrew cache: \(cachePurgingError.localizedDescription)")

                            sendNotification(
                                title: String(localized: "maintenance.results.package-cache.failure"),
                                body: String(localized: "maintenance.results.package-cache.failure.details-\(cachePurgingError.localizedDescription)"),
                                sensitivity: .active
                            )
                        }
                    }
                }
            }
            else
            {
                Text("maintenance.step.purging-cache")
            }

            if !isDeletingCachedDownloads
            {
                Button(appDelegate.appState.cachedDownloadsFolderSize != 0 ? "maintenance.steps.downloads.delete-cached-downloads" : "navigation.menu.maintenance.no-cached-downloads")
                {
                    print("Will delete cached downloads")

                    isDeletingCachedDownloads = true

                    let reclaimedSpaceAfterCachePurge = Int(appDelegate.appState.cachedDownloadsFolderSize)

                    deleteCachedDownloads()

                    sendNotification(
                        title: String(localized: "maintenance.results.cached-downloads"),
                        body: String(localized: "maintenance.results.cached-downloads.summary-\(reclaimedSpaceAfterCachePurge.formatted(.byteCount(style: .file)))"),
                        sensitivity: .active
                    )

                    isDeletingCachedDownloads = false

                    appDelegate.appState.cachedDownloadsFolderSize = directorySize(url: AppConstants.brewCachedDownloadsPath)
                }
                .disabled(appDelegate.appState.cachedDownloadsFolderSize == 0)
            }
            else
            {
                Text("maintenance.step.deleting-cached-downloads")
            }


            Divider()

            Button("menubar.open.cork")
            {
                openWindow(id: "main")

                switchCorkToForeground()
            }

            Divider()

            Button("action.quit")
            {
                NSApp.terminate(self)
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
            if outdatedPackageTracker.outdatedPackages.count > 0
            {
                NSApp.dockTile.badgeLabel = String(outdatedPackageTracker.outdatedPackages.count)
            }
        }
        else if outdatedPackageNotificationType == .notification || outdatedPackageNotificationType == .none
        {
            NSApp.dockTile.badgeLabel = ""
        }
    }
}
