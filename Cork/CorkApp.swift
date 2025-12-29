//
//  CorkApp.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

// swiftlint:disable file_length

import ButtonKit
import CorkNotifications
import CorkShared
import DavidFoundation
import Defaults
import SwiftData
import SwiftUI
import UserNotifications
import CorkModels
import CorkTerminalFunctions

@main
struct CorkApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate

    @State var brewPackagesTracker: BrewPackagesTracker = .init()
    @State var tapTracker: TapTracker = .init()

    @State var cachedDownloadsTracker: CachedDownloadsTracker = .init()

    @State var topPackagesTracker: TopPackagesTracker = .init()

    @State var updateProgressTracker: UpdateProgressTracker = .init()
    @State var outdatedPackagesTracker: OutdatedPackagesTracker = .init()

    @Default(.demoActivatedAt) var demoActivatedAt: Date?
    @Default(.hasValidatedEmail) var hasValidatedEmail: Bool

    @Default(.hasFinishedOnboarding) var hasFinishedOnboarding: Bool

    @Default(.hasFinishedLicensingWorkflow) var hasFinishedLicensingWorkflow: Bool

    @Environment(\.openWindow) private var openWindow: OpenWindowAction

    @Default(.showInMenuBar) var showInMenuBar: Bool

    @Default(.areNotificationsEnabled) var areNotificationsEnabled: Bool
    @Default(.outdatedPackageNotificationType) var outdatedPackageNotificationType: OutdatedPackageNotificationType

    @Default(.lastSubmittedCorkVersion) var lastSubmittedCorkVersion: String

    @AppStorage("defaultBackupDateFormat") var defaultBackupDateFormat: Date.FormatStyle.DateStyle = .numeric

    @State private var sendStandardUpdatesAvailableNotification: Bool = true

    @State private var brewfileContents: String = .init()
    @State private var isShowingBrewfileExporter: Bool = false

    @State private var isShowingBrewfileImporter: Bool = false

    let backgroundUpdateTimer: NSBackgroundActivityScheduler = {
        let scheduler: NSBackgroundActivityScheduler = .init(identifier: "com.davidbures.Cork.backgroundAutoUpdate")
        scheduler.repeats = true
        scheduler.interval = AppConstants.shared.backgroundUpdateInterval
        scheduler.tolerance = AppConstants.shared.backgroundUpdateIntervalTolerance
        scheduler.qualityOfService = .background

        return scheduler
    }()

    var body: some Scene
    {
        Window("Main Window", id: .mainWindowID)
        {
            switch hasFinishedLicensingWorkflow
            {
            case true:
                mainWindow
            case false:
                LicensingView()
                    .environment(appDelegate.appState)
                    .modify
                    { viewProxy in
                        if #available(macOS 15, *)
                        {
                            viewProxy
                                .containerBackground(.thinMaterial, for: .window)
                                .toolbarVisibility(.automatic, for: .windowToolbar)
                        }
                        else
                        {
                            viewProxy
                        }
                    }
                    .navigationTitle(String(localized: "app-name"))
                    .navigationSubtitle(String(localized: "licensing.title"))
            }
            
        }
        .commands
        {
            Group // These groups have to be here otherwise SwiftUI shits the bed. No other reason at all 🤦
            {
                CommandGroup(replacing: .appInfo)
                {
                    aboutMenuBarSection
                }
                CommandGroup(before: .help) // The "Report Bugs" section
                {
                    bugReportingMenuBarSection
                }

                CommandGroup(before: .systemServices)
                {
                    onboardingMenuBarSection
                }

                SidebarCommands()
                CommandGroup(replacing: .newItem) // Disables "New Window"
                {}

                CommandGroup(before: .sidebar)
                {
                    goToHomeScreenMenuBarSection
                }
            }

            Group
            {
                CommandGroup(before: .newItem)
                {
                    backupAndRestoreMenuBarSection
                }

                CommandGroup(after: .newItem)
                {
                    searchMenuBarSection
                }

                CommandMenu("navigation.menu.packages")
                {
                    packagesMenuBarSection
                }

                CommandMenu("navigation.menu.services")
                {
                    servicesMenuBarSection
                }

                CommandMenu("navigation.menu.maintenance")
                {
                    maintenanceMenuBarSection
                }

                #if DEBUG
                    CommandMenu("debug.navigation")
                    {
                        debugMenuBarSection
                    }
                #endif
            }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)

        Window("window.services", id: .servicesWindowID)
        {
            HomebrewServicesView()
        }
        .commands
        {}
        .windowToolbarStyle(.unifiedCompact)

        Window("window.about", id: .aboutWindowID)
        {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        WindowGroup(id: .previewWindowID, for: MinimalHomebrewPackage.self)
        { $packageToPreview in
            
            let convertedMinimalPackage: BrewPackage? = BrewPackage(using: packageToPreview)
            
            PackagePreview(packageToPreview: convertedMinimalPackage)
                .navigationTitle(packageToPreview?.name ?? "")
                .environment(appDelegate.appState)
                .environment(brewPackagesTracker)
                .environment(outdatedPackagesTracker)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)

        WindowGroup(id: .errorInspectorWindowID, for: String.self)
        { $errorToInspect in
            if let errorToInspect
            {
                ErrorInspector(errorText: errorToInspect)
            }
        }
        .windowToolbarStyle(.unifiedCompact)

        Settings
        {
            SettingsView()
                .environment(appDelegate.appState)
        }
        .windowResizability(.contentSize)

        // MARK: - Menu Bar Extra

        MenuBarExtra("app-name", systemImage: outdatedPackagesTracker.displayableOutdatedPackages.isEmpty ? "mug" : "mug.fill", isInserted: $showInMenuBar)
        {
            MenuBarItem()
                .environment(appDelegate.appState)
                .environment(brewPackagesTracker)
                .environment(tapTracker)
                .environment(cachedDownloadsTracker)
                .environment(outdatedPackagesTracker)
        }
    }

    // MARK: - Main App ViewBuilder
    @ViewBuilder
    var mainWindow: some View
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
            .environment(appDelegate.appState)
            .environment(brewPackagesTracker)
            .environment(tapTracker)
            .environment(cachedDownloadsTracker)
            .environment(updateProgressTracker)
            .environment(outdatedPackagesTracker)
            .environment(topPackagesTracker)
            .modelContainer(for: [
                SavedTaggedPackage.self,
                ExcludedAdoptableApp.self
            ])
            .task
            {
                NSWindow.allowsAutomaticWindowTabbing = false

                if areNotificationsEnabled
                {
                    await appDelegate.appState.setupNotifications()
                }
            }
            .task
            {
                if lastSubmittedCorkVersion.isEmpty
                { /// Make sure we have a Cork version to check against
                    let currentCorkVersion: String = "1.4.1"

                    #if DEBUG
                        AppConstants.shared.logger.debug("There's no saved Cork version - Will save 1.4.1")
                    #endif

                    lastSubmittedCorkVersion = currentCorkVersion
                }

                if lastSubmittedCorkVersion != String(NSApplication.appVersion!)
                { /// Submit the version if this version has not already been submitted
                    #if DEBUG
                        AppConstants.shared.logger.debug("Last submitted version doesn't match current version")
                    #endif

                    try? await submitSystemVersion()
                }
                else
                {
                    #if DEBUG
                        AppConstants.shared.logger.debug("Last submitted version matches the current version")
                    #endif
                }
            }
            .onAppear
            {
                handleLicensing()
            }
            .onAppear
            {
                handleBackgroundUpdating()
            }
            .onChange(of: demoActivatedAt) // React to when the user activates the demo
            { _, newValue in
                handleDemoTiming(newValue: newValue)
            }
            .onChange(of: outdatedPackagesTracker.displayableOutdatedPackages.count)
            { _, outdatedPackageCount in
                handleOutdatedPackageChangeAppBadge(outdatedPackageCount: outdatedPackageCount)
            }
            .onChange(of: outdatedPackageNotificationType) // Set the correct app badge number when the user changes their notification settings
            { _, newValue in
                setAppBadge(outdatedPackageNotificationType: newValue)
            }
            .onChange(of: areNotificationsEnabled)
            { _, newValue in // Remove the badge from the app icon if the user turns off notifications, put it back when they turn them back on
                Task
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
                defaultFilename: defaultBackupDateFormat != .omitted ? String(localized: "brewfile.export.default-export-name-\(Date().formatted(date: defaultBackupDateFormat, time: .omitted))") : String(localized: "brewfile.export.default-export-name.empty")
            )
            { result in
                switch result
                {
                case .success(let success):
                    AppConstants.shared.logger.log("Succeeded in exporting: \(success, privacy: .public)")
                case .failure(let failure):
                    AppConstants.shared.logger.error("Failed in exporting: \(failure, privacy: .public)")
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
                case .success(let success):
                    AppConstants.shared.logger.debug("Succeeded in importing: \(success, privacy: .public)")
                case .failure(let failure):
                    AppConstants.shared.logger.error("Failed in importing: \(failure, privacy: .public)")
                }
            }
    }
    
    // MARK: - Menu Bar ViewBuilders

    @ViewBuilder
    var aboutMenuBarSection: some View
    {
        Button
        {
            openWindow(id: .aboutWindowID)
        } label: {
            Label("navigation.about", systemImage: "info.circle")
        }
    }

    @ViewBuilder
    var bugReportingMenuBarSection: some View
    {
        #if !SELF_COMPILED
            Menu
            {
                Button
                {
                    NSWorkspace.shared.open(URL(string: "https://github.com/buresdv/Cork/issues/new?assignees=&labels=Bug&projects=&template=bug_report.yml")!)
                } label: {
                    Label("action.report-bugs.git-hub", systemImage: "exclamationmark.bubble")
                }

                /*
                ButtonThatOpensWebsites(
                    websiteURL: URL(string: "https://forum.rikidar.eu/forumdisplay.php?fid=8")!, buttonText: "actiton.report-bugs.forum"
                )
                 */

                /*
                 Button
                 {
                     let emailSubject = "Cork Error Report: v\(NSApplication.appVersion!)-\(NSApplication.buildVersion!)"
                     let emailBody = "This is what went wrong:\n\nThis is what I expected to happen:\n\nDid Cork crash?"

                     let emailService = NSSharingService(named: NSSharingService.Name.composeEmail)
                     emailService?.recipients = ["bug-reporting@corkmac.app"]
                     emailService?.subject = emailSubject
                     emailService?.perform(withItems: [emailBody])

                 } label: {
                     Text("action.report-bugs.email")
                 }
                  */

            } label: {
                Text("action.report-bugs.menu-category")
            }

            Divider()
        #endif
    }

    @ViewBuilder
    var onboardingMenuBarSection: some View
    {
        Button
        {
            hasFinishedOnboarding = false
        } label: {
            Label("onboarding.start", systemImage: "person.crop.circle.badge.checkmark")
        }
        .disabled(!hasFinishedOnboarding)

        Button
        {
            hasFinishedLicensingWorkflow = false
        } label: {
            Label("licensing.title", systemImage: "checkmark.seal")
        }

        Divider()
    }

    @ViewBuilder
    var goToHomeScreenMenuBarSection: some View
    {
        Button
        {
            appDelegate.appState.navigationManager.dismissScreen()
        } label: {
            Label("action.go-to-status-page.menu-bar", systemImage: "house")
        }
        .disabled(!appDelegate.appState.navigationManager.isAnyScreenOpened)
        Divider()
    }

    @ViewBuilder
    var backupAndRestoreMenuBarSection: some View
    {
        AsyncButton
        {
            do
            {
                brewfileContents = try await exportBrewfile(appState: appDelegate.appState)

                isShowingBrewfileExporter = true
            }
            catch let brewfileExportError as BrewfileDumpingError
            {
                AppConstants.shared.logger.error("\(brewfileExportError)")

                switch brewfileExportError
                {
                case .couldNotDetermineWorkingDirectory:
                    appDelegate.appState.showAlert(errorToShow: .couldNotGetWorkingDirectory)

                case .errorWhileDumpingBrewfile(let error):
                    appDelegate.appState.showAlert(errorToShow: .couldNotDumpBrewfile(error: error))

                case .couldNotReadBrewfile:
                    appDelegate.appState.showAlert(errorToShow: .couldNotReadBrewfile(error: brewfileExportError.localizedDescription))
                }
            }
        } label: {
            Label("navigation.menu.import-export.export-brewfile", systemImage: "square.and.arrow.up")
        }
        .asyncButtonStyle(.plainStyle)

        AsyncButton
        {
            do
            {
                let picker: NSOpenPanel = .init()
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

                    AppConstants.shared.logger.debug("\(brewfileURL.path)")

                    do
                    {
                        try await importBrewfile(from: brewfileURL, appState: appDelegate.appState, brewPackagesTracker: brewPackagesTracker, cachedDownloadsTracker: cachedDownloadsTracker)
                    }
                    catch let brewfileImportingError
                    {
                        AppConstants.shared.logger.error("\(brewfileImportingError.localizedDescription, privacy: .public)")

                        appDelegate.appState.showAlert(errorToShow: .malformedBrewfile)

                        appDelegate.appState.showSheet(ofType: .brewfileImport)
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
        } label: {
            Label("navigation.menu.import-export.import-brewfile", systemImage: "square.and.arrow.down")
        }
        .asyncButtonStyle(.plainStyle)
    }

    @ViewBuilder
    var searchMenuBarSection: some View
    {
        Divider()

        Button
        {
            appDelegate.appState.isSearchFieldFocused = true
        } label: {
            Label("navigation.menu.search", systemImage: "magnifyingglass")
        }
        .keyboardShortcut("f", modifiers: .command)
    }

    @ViewBuilder
    var packagesMenuBarSection: some View
    {
        InstallPackageButton(appState: appDelegate.appState)
            .keyboardShortcut("n")

        AddTapButton(appState: appDelegate.appState)
            .keyboardShortcut("n", modifiers: [.command, .option])

        Divider()

        CheckForOutdatedPackagesButton()
            .keyboardShortcut("r")
            .environment(appDelegate.appState)
            .environment(outdatedPackagesTracker)
        
        UpgradePackagesButton(appState: appDelegate.appState)
            .keyboardShortcut("r", modifiers: [.control, .command])        
    }

    @ViewBuilder
    var servicesMenuBarSection: some View
    {
        Button
        {
            openWindow(id: .servicesWindowID)
        } label: {
            Label("navigation.menu.services.open-window", systemImage: "square.stack.3d.down.right")
        }
        .keyboardShortcut("s", modifiers: .command)
    }

    @ViewBuilder
    var maintenanceMenuBarSection: some View
    {
        OpenMaintenanceSheetButton(appState: appDelegate.appState, labelType: .performMaintenance)
            .keyboardShortcut("m", modifiers: [.command, .shift])

        DeleteCachedDownloadsButton(appState: appDelegate.appState)
            .keyboardShortcut("m", modifiers: [.command, .option])
            .disabled(cachedDownloadsTracker.cachedDownloadsSize == 0)
    }

    @ViewBuilder
    var debugMenuBarSection: some View
    {
        Menu
        {
            Button
            {
                demoActivatedAt = nil
                hasValidatedEmail = false
                appDelegate.appState.licensingState = .notBoughtOrHasNotActivatedDemo
                hasFinishedLicensingWorkflow = false
            } label: {
                Text("debug.action.reset-license-state")
            }

            Button
            {
                demoActivatedAt = nil
                hasValidatedEmail = false
                appDelegate.appState.licensingState = .demo
                hasFinishedLicensingWorkflow = false
            } label: {
                Text("debug.action.activate-demo")
            }
        } label: {
            Text("debug.action.licensing")
        }

        Menu
        {
            Button
            {
                openWindow(id: .errorInspectorWindowID, value: BrewPackage.PackageLoadingError.packageIsNotAFolder("Hello I am an error", packageURL: .applicationDirectory).localizedDescription)
            } label: {
                Text("debug.action.show-error-inspector")
            }
        } label: {
            Text("debug.action.ui")
        }
    }
    
    // MARK: - Functions
    
    // MARK: - App badge
    func setAppBadge(outdatedPackageNotificationType: OutdatedPackageNotificationType)
    {
        if outdatedPackageNotificationType == .badge || outdatedPackageNotificationType == .both
        {
            if !outdatedPackagesTracker.displayableOutdatedPackages.isEmpty
            {
                NSApp.dockTile.badgeLabel = String(outdatedPackagesTracker.displayableOutdatedPackages.count)
            }
        }
        else if outdatedPackageNotificationType == .notification || outdatedPackageNotificationType == .none
        {
            NSApp.dockTile.badgeLabel = ""
        }
    }
    
    private func setWhetherToSendStandardUpdatesAvailableNotification(to newValue: Bool)
    {
        self.sendStandardUpdatesAvailableNotification = newValue
    }
    
    func handleOutdatedPackageChangeAppBadge(outdatedPackageCount: Int)
    {
        AppConstants.shared.logger.debug("Number of displayable outdated packages changed (\(outdatedPackageCount))")

        // TODO: Remove this once I figure out why the updating spinner sometimes doesn't disappear
        withAnimation
        {
            outdatedPackagesTracker.isCheckingForPackageUpdates = false
        }

        if outdatedPackageCount == 0
        {
            NSApp.dockTile.badgeLabel = ""
        }
        else
        {
            if areNotificationsEnabled
            {
                if outdatedPackageNotificationType == .badge || outdatedPackageNotificationType == .both
                {
                    NSApp.dockTile.badgeLabel = String(outdatedPackageCount)
                }

                // TODO: Changing the package display type sends a notificaiton, which is not visible since the app is in the foreground. Once macOS 15 comes out, move `sendStandardUpdatesAvailableNotification` into the AppState and suppress it
                if outdatedPackageNotificationType == .notification || outdatedPackageNotificationType == .both
                {
                    AppConstants.shared.logger.log("Will try to send notification")

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
    
    // MARK: - Background updating
    
    func handleBackgroundUpdating()
    {
        // Start the background update scheduler when the app starts
        backgroundUpdateTimer.schedule
        { (completion: NSBackgroundActivityScheduler.CompletionHandler) in
            AppConstants.shared.logger.log("Scheduled event fired at \(Date(), privacy: .auto)")

            Task
            {
                var updateResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["update"])

                AppConstants.shared.logger.debug("Update result:\nStandard output: \(updateResult.standardOutput, privacy: .public)\nStandard error: \(updateResult.standardError, privacy: .public)")

                do
                {
                    let temporaryOutdatedPackageTracker: OutdatedPackagesTracker = await .init()

                    try await temporaryOutdatedPackageTracker.getOutdatedPackages(brewPackagesTracker: brewPackagesTracker)

                    var newOutdatedPackages: Set<OutdatedPackage> = await temporaryOutdatedPackageTracker.outdatedPackages

                    AppConstants.shared.logger.debug("Outdated packages checker output: \(newOutdatedPackages, privacy: .public)")

                    defer
                    {
                        AppConstants.shared.logger.log("Will purge temporary update trackers")

                        updateResult = .init(standardOutput: "", standardError: "")
                        newOutdatedPackages = .init()
                    }

                    if await newOutdatedPackages.count > outdatedPackagesTracker.outdatedPackages.count
                    {
                        AppConstants.shared.logger.log("New updates found")

                        /// Set this to `true` so the normal notification doesn't get sent
                        await setWhetherToSendStandardUpdatesAvailableNotification(to: false)

                        let differentPackages: Set<OutdatedPackage> = await newOutdatedPackages.subtracting(outdatedPackagesTracker.displayableOutdatedPackages)
                        AppConstants.shared.logger.debug("Changed packages: \(differentPackages, privacy: .auto)")

                        sendNotification(title: String(localized: "notification.new-outdated-packages-found.title"), subtitle: differentPackages.map(\.package.name).formatted(.list(type: .and)))

                        await outdatedPackagesTracker.setOutdatedPackages(to: newOutdatedPackages)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                        {
                            sendStandardUpdatesAvailableNotification = true
                        }
                    }
                    else
                    {
                        AppConstants.shared.logger.log("No new updates found")
                    }
                }
                catch
                {
                    AppConstants.shared.logger.error("Something got fucked up about checking for outdated packages")
                }
            }

            completion(NSBackgroundActivityScheduler.Result.finished)
        }
    }
    
    // MARK: - Licensing
    func handleLicensing()
    {
        print("Licensing state: \(appDelegate.appState.licensingState)")

        #if SELF_COMPILED
            AppConstants.shared.logger.debug("Will set licensing state to Self Compiled")
            appDelegate.appState.licensingState = .selfCompiled
        #else
            if !hasValidatedEmail
            {
                if appDelegate.appState.licensingState != .selfCompiled
                {
                    if let demoActivatedAt
                    {
                        let timeDemoWillRunOutAt: Date = demoActivatedAt + AppConstants.shared.demoLengthInSeconds

                        AppConstants.shared.logger.debug("There is \(demoActivatedAt.timeIntervalSinceNow.formatted()) to go on the demo")

                        AppConstants.shared.logger.debug("Demo will time out at \(timeDemoWillRunOutAt.formatted(date: .complete, time: .complete))")

                        if ((demoActivatedAt.timeIntervalSinceNow) + AppConstants.shared.demoLengthInSeconds) > 0
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
        #endif
    }
    
    func handleDemoTiming(newValue: Date?)
    {
        if let newValue
        { // If the demo has not been activated, `demoActivatedAt` is nil. So, when it's not nil anymore, it means the user activated it
            AppConstants.shared.logger.debug("The user activated the demo at \(newValue.formatted(date: .complete, time: .complete), privacy: .public)")
            hasFinishedLicensingWorkflow = true
        }
    }
}

