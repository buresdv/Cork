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

    @AppStorage("demoActivatedAt") var demoActivatedAt: Date?
    @AppStorage("hasValidatedEmail") var hasValidatedEmail: Bool = false

    @AppStorage("hasFinishedOnboarding") var hasFinishedOnboarding: Bool = false

    @AppStorage("hasFinishedLicensingWorkflow") var hasFinishedLicensingWorkflow: Bool = false

    @Environment(\.openWindow) private var openWindow
    @AppStorage("showInMenuBar") var showInMenuBar = false

    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge

    @State private var sendStandardUpdatesAvailableNotification: Bool = true

    @State private var brewfileContents: String = .init()
    @State private var isShowingBrewfileExporter: Bool = false

    @State private var isShowingBrewfileImporter: Bool = false
    
    @AppStorage("hasSuccessfullySubmittedOSVersion") var hasSuccessfullySubmittedOSVersion: Bool = false

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
        Window("Main Window", id: .mainWindowID)
        {
            ContentView()
                .sheet(isPresented: !$hasFinishedOnboarding, onDismiss: {
                    hasFinishedOnboarding = true
                }, content: {
                    OnboardingView()
                })
                .sheet(isPresented: !$hasFinishedLicensingWorkflow, onDismiss: {
                    hasFinishedLicensingWorkflow = true
                }, content: {
                    LicensingView()
                        .interactiveDismissDisabled()
                })
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
                .task // TODO: Remove this later
                {
                    if !hasSuccessfullySubmittedOSVersion
                    {
                        try? await submitSystemVersion()
                    }
                }
                .onAppear
                {
                    if !hasValidatedEmail
                    {
                        if let demoActivatedAt
                        {
                            var timeDemoWillRunOutAt: Date = demoActivatedAt + AppConstants.demoLengthInSeconds
                            
                            AppConstants.logger.debug("There is \(demoActivatedAt.timeIntervalSinceNow.formatted()) to go on the demo")
                            
                            AppConstants.logger.debug("Demo will time out at \(timeDemoWillRunOutAt.formatted(date: .complete, time: .complete))")
                            
                            if ((demoActivatedAt.timeIntervalSinceNow) + AppConstants.demoLengthInSeconds) > 0
                            { // Check if there is still time on the demo
                              /// do stuff if there is
                            }
                            else
                            {
                                hasFinishedLicensingWorkflow = false
                            }
                        }
                    }
                }
                .onAppear
                {
                    // Start the background update scheduler when the app starts
                    backgroundUpdateTimer.schedule
                    { (completion: NSBackgroundActivityScheduler.CompletionHandler) in
                        AppConstants.logger.log("Scheduled event fired at \(Date(), privacy: .auto)")

                        Task(priority: .background)
                        {
                            var updateResult = await shell(AppConstants.brewExecutablePath, ["update"])

                            AppConstants.logger.debug("Update result:\nStandard output: \(updateResult.standardOutput, privacy: .public)\nStandard error: \(updateResult.standardError, privacy: .public)")

                            do
                            {
                                var newOutdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)

                                AppConstants.logger.debug("Outdated packages checker output: \(newOutdatedPackages, privacy: .public)")

                                defer
                                {
                                    AppConstants.logger.log("Will purge temporary update trackers")

                                    updateResult = .init(standardOutput: "", standardError: "")
                                    newOutdatedPackages = .init()
                                }

                                if newOutdatedPackages.count > outdatedPackageTracker.outdatedPackages.count
                                {
                                    AppConstants.logger.log("New updates found")

                                    /// Set this to `true` so the normal notification doesn't get sent
                                    sendStandardUpdatesAvailableNotification = false

                                    let differentPackages = newOutdatedPackages.subtracting(outdatedPackageTracker.outdatedPackages)
                                    AppConstants.logger.debug("Changed packages: \(differentPackages, privacy: .auto)")

                                    sendNotification(title: String(localized: "notification.new-outdated-packages-found.title"), subtitle: differentPackages.map(\.package.name).formatted(.list(type: .and)))

                                    outdatedPackageTracker.outdatedPackages = newOutdatedPackages

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                                    {
                                        sendStandardUpdatesAvailableNotification = true
                                    }
                                }
                                else
                                {
                                    AppConstants.logger.log("No new updates found")
                                }
                            }
                            catch
                            {
                                AppConstants.logger.error("Something got fucked up about checking for outdated packages")
                            }
                        }

                        completion(NSBackgroundActivityScheduler.Result.finished)
                    }
                }
                .onChange(of: demoActivatedAt) // React to when the user activates the demo
                { newValue in
                    if let newValue
                    { // If the demo has not been activated, `demoActivatedAt` is nil. So, when it's not nil anymore, it means the user activated it
                        AppConstants.logger.debug("The user activated the demo at \(newValue.formatted(date: .complete, time: .complete), privacy: .public)")
                        hasFinishedLicensingWorkflow = true
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
                                AppConstants.logger.log("Will try to send notification")

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
                    Task(priority: .background)
                    {
                        await appDelegate.appState.requestNotificationAuthorization()

                        if appDelegate.appState.notificationEnabledInSystemSettings == true
                        {
                            await appDelegate.appState.requestNotificationAuthorization()
                            if appDelegate.appState.notificationAuthStatus == .denied
                            {
                                areNotificationsEnabled = false
                            }
                        }
                    }

                    if newValue == false
                    {
                        NSApp.dockTile.badgeLabel = ""
                    }
                    else
                    {
                        setAppBadge(outdatedPackageNotificationType: outdatedPackageNotificationType)
                    }
                }
                .fileExporter(
                    isPresented: $isShowingBrewfileExporter,
                    document: StringFile(initialText: brewfileContents),
                    contentType: .homebrewBackup,
                    defaultFilename: String(localized: "brewfile.export.default-export-name-\(Date().formatted(date: .numeric, time: .omitted))")
                )
                { result in
                    switch result
                    {
                    case let .success(success):
                        AppConstants.logger.log("Succeeded in exporting: \(success, privacy: .public)")
                    case let .failure(failure):
                        AppConstants.logger.error("Failed in exporting: \(failure, privacy: .public)")
                    }
                }
                .fileImporter(
                    isPresented: $isShowingBrewfileImporter,
                    allowedContentTypes: [.homebrewBackup],
                    allowsMultipleSelection: false
                )
                { result in
                    switch result
                    {
                    case let .success(success):
                        AppConstants.logger.debug("Succeeded in importing: \(success, privacy: .public)")
                    case let .failure(failure):
                        AppConstants.logger.error("Failed in importing: \(failure, privacy: .public)")
                    }
                }
        }
        .commands
        {
            CommandGroup(replacing: .appInfo)
            {
                Button
                {
                    openWindow(id: .aboutWindowID)
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

                Button
                {
                    NSWorkspace.shared.open(URL(string: "https://feedback.corkmac.app")!)
                } label: {
                    Text("action.submit-feedback")
                }

                Divider()
            }

            CommandGroup(before: .systemServices)
            {
                Button
                {
                    hasFinishedOnboarding = false
                } label: {
                    Text("onboarding.start")
                }
                .disabled(!hasFinishedOnboarding)
                
                Button
                {
                    hasFinishedLicensingWorkflow = false
                } label: {
                    Text("licensing.title")
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

            CommandGroup(before: .newItem)
            {
                Button
                {
                    Task(priority: .userInitiated)
                    {
                        do
                        {
                            brewfileContents = try await exportBrewfile(appState: appDelegate.appState)

                            isShowingBrewfileExporter = true
                        }
                        catch let brewfileExportError as BrewfileDumpingError
                        {
                            switch brewfileExportError
                            {
                            case .couldNotDetermineWorkingDirectory:
                                    appDelegate.appState.showAlert(errorToShow: .couldNotGetWorkingDirectory)

                            case .errorWhileDumpingBrewfile:
                                appDelegate.appState.showAlert(errorToShow: .couldNotDumpBrewfile)

                            case .couldNotReadBrewfile:
                                appDelegate.appState.showAlert(errorToShow: .couldNotReadBrewfile)
                            }
                        }
                    }
                } label: {
                    Text("navigation.menu.import-export.export-brewfile")
                }

                Button
                {
                    Task(priority: .userInitiated)
                    {
                        do
                        {
                            let picker = NSOpenPanel()
                            picker.allowsMultipleSelection = false
                            picker.canChooseDirectories = false
                            picker.allowedFileTypes = ["brewbak", ""]

                            if picker.runModal() == .OK
                            {
                                guard let brewfileURL = picker.url
                                else
                                {
                                    throw BrewfileReadingError.couldNotGetBrewfileLocation
                                }

                                AppConstants.logger.debug("\(brewfileURL.path)")

                                do
                                {
                                    try await importBrewfile(from: brewfileURL, appState: appDelegate.appState, brewData: brewData)
                                }
                                catch
                                {
                                    appDelegate.appState.showAlert(errorToShow: .malformedBrewfile)
                                    
                                    appDelegate.appState.isShowingBrewfileImportProgress = false
                                }
                            }
                        }
                        catch let error as BrewfileReadingError
                        {
                            switch error
                            {
                            case .couldNotGetBrewfileLocation:
                                appDelegate.appState.showAlert(errorToShow: .couldNotGetBrewfileLocation)

                            case .couldNotImportFile:
                                appDelegate.appState.showAlert(errorToShow: .couldNotImportBrewfile)
                            }
                        }
                    }
                } label: {
                    Text("navigation.menu.import-export.import-brewfile")
                }
            }

            CommandGroup(after: .newItem)
            {
                Divider()

                Button
                {
                    appDelegate.appState.isSearchFieldFocused = true
                } label: {
                    Text("navigation.menu.search")
                }
                .keyboardShortcut("f", modifiers: .command)
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

                Button
                {
                    appDelegate.appState.isShowingFastCacheDeletionMaintenanceView.toggle()
                } label: {
                    Text("navigation.menu.maintenance.delete-cached-downloads")
                }
                .keyboardShortcut("m", modifiers: [.command, .option])
                .disabled(appDelegate.appState.cachedDownloadsFolderSize == 0)
            }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
        
        Window("Homebrew Services", id: .servicesWindowID)
        {
            HomebrewServicesView()
        }
        .commands {
            
        }
        .windowToolbarStyle(.unifiedCompact)
        
        Window("About", id: .aboutWindowID)
        {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Settings
        {
            SettingsView()
                .environmentObject(appDelegate.appState)
        }
        MenuBarExtra("app-name", systemImage: outdatedPackageTracker.outdatedPackages.count == 0 ? "mug" : "mug.fill", isInserted: $showInMenuBar)
        {
            MenuBarItem()
                .environmentObject(appDelegate.appState)
                .environmentObject(brewData)
                .environmentObject(availableTaps)
                .environmentObject(outdatedPackageTracker)
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
