//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

// swiftlint:disable file_length

import CorkShared
import SwiftUI
import ButtonKit

struct ContentView: View, Sendable
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .byInstallDate
    @AppStorage("allowBrewAnalytics") var allowBrewAnalytics: Bool = true

    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge

    @AppStorage("enableDiscoverability") var enableDiscoverability: Bool = false
    @AppStorage("discoverabilityDaySpan") var discoverabilityDaySpan: DiscoverabilityDaySpans = .month
    @AppStorage("sortTopPackagesBy") var sortTopPackagesBy: TopPackageSorting = .mostDownloads

    @AppStorage("customHomebrewPath") var customHomebrewPath: String = ""

    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var tapData: TapTracker
    
    @EnvironmentObject var cachedDownloadsTracker: CachedPackagesTracker

    @EnvironmentObject var topPackagesTracker: TopPackagesTracker

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @State private var multiSelection: Set<UUID> = .init()
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    @State fileprivate var corruptedPackage: CorruptedPackage?

    // MARK: - ViewBuilders

    @ViewBuilder private var upgradePackagesButton: some View
    {
        Button
        {
            appState.showSheet(ofType: .fullUpdate)
        } label: {
            Label
            {
                Text("navigation.upgrade-packages")
            } icon: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .help("navigation.upgrade-packages.help")
        .disabled(self.appState.isCheckingForPackageUpdates)
    }

    @ViewBuilder private var addTapButton: some View
    {
        Button
        {
            appState.showSheet(ofType: .tapAddition)
        } label: {
            Label
            {
                Text("navigation.add-tap")
            } icon: {
                Image(systemName: "spigot")
            }
        }
        .help("navigation.add-tap.help")
    }

    @ViewBuilder private var installPackageButton: some View
    {
        Button
        {
            appState.showSheet(ofType: .packageInstallation)
        } label: {
            Label
            {
                Text("navigation.install-package")
            } icon: {
                Image(systemName: "plus")
            }
        }
        .help("navigation.install-package.help")
    }

    @ViewBuilder private var performMaintenanceButton: some View
    {
        Button
        {
            appState.showSheet(ofType: .maintenance(fastCacheDeletion: false))
        } label: {
            Label("start-page.open-maintenance", systemImage: "arrow.3.trianglepath")
        }
        .help("navigation.maintenance.help")
    }

    @ViewBuilder private var manageServicesButton: some View
    {
        Button
        {
            self.openWindow(id: .servicesWindowID)
        } label: {
            Label("navigation.manage-services", systemImage: "square.stack.3d.down.right")
        }
        .help("navigation.manage-services.help")
    }

    // MARK: - The main view

    var body: some View
    {
        NavigationSplitView(columnVisibility: self.$columnVisibility)
        {
            SidebarView()
                .navigationDestination(for: BrewPackage.self)
                { brewPackage in
                    PackageDetailView(package: brewPackage)
                        .id(brewPackage.id)
                }
                .navigationDestination(for: BrewTap.self)
                { brewTap in
                    TapDetailView(tap: brewTap)
                        .id(brewTap.id)
                }
        } detail: {
            NavigationStack
            {
                StartPage()
                    .frame(minWidth: 600, minHeight: 500)
            }
        }
        .navigationTitle("app-name")
        .navigationSubtitle("navigation.installed-packages.count-\(self.brewData.numberOfInstalledPackages)")
        .toolbar(id: "PackageActions")
        {
            ToolbarItem(id: "upgradePackages", placement: .primaryAction)
            {
                self.upgradePackagesButton
            }

            ToolbarItem(id: "addTap", placement: .primaryAction)
            {
                self.addTapButton
            }

            ToolbarItem(id: "installPackage", placement: .primaryAction)
            {
                self.installPackageButton
            }

            ToolbarItem(id: "maintenance", placement: .primaryAction)
            {
                self.performMaintenanceButton
            }
            .defaultCustomization(.hidden)

            ToolbarItem(id: "manageServices", placement: .primaryAction)
            {
                self.manageServicesButton
            }
            .defaultCustomization(.hidden)

            ToolbarItem(id: "spacer", placement: .automatic)
            {
                Spacer()
            }
            .defaultCustomization(.hidden)

            ToolbarItem(id: "divider", placement: .automatic)
            {
                Divider()
            }
            .defaultCustomization(.hidden)

            // TODO: Implement this button
            /*
             ToolbarItem(id: "installPackageDirectly", placement: .automatic)
             {
                 Button
                 {
                     AppConstants.shared.logger.info("Ahoj")
                 } label: {
                     Label
                     {
                         Text("navigation.install-package.direct")
                     } icon: {
                         Image(systemName: "plus.viewfinder")
                     }
                 }
                 .help("navigation.install-package.direct.help")
             }
             .defaultCustomization(.hidden)
              */
        }
        .basicsSetup(of: self)
        .packageLoadingTask(of: self)
        .tapLoadingTask(of: self)
        .analyticsSetupTask(of: self)
        .cachedDownloadsCalculationTask(of: self)
        .onChanges(boundToView: self)
        .sheets(of: self)
        .alerts(of: self)
        .confirmationDialogs(of: self)
        .topPackagesLoadingTask(of: self)
    }
}

// MARK: - View extensions

private extension View
{
    func basicsSetup(of view: ContentView) -> some View
    {
        self
            .onAppear
            {
                AppConstants.shared.logger.debug("Brew executable path: \(AppConstants.shared.brewExecutablePath, privacy: .public)")

                if !view.customHomebrewPath.isEmpty && !FileManager.default.fileExists(atPath: AppConstants.shared.brewExecutablePath.path)
                {
                    view.appState.showAlert(errorToShow: .customBrewExcutableGotDeleted)
                }

                AppConstants.shared.logger.debug("Documents directory: \(AppConstants.shared.documentsDirectoryPath.path, privacy: .public)")

                AppConstants.shared.logger.debug("System version: \(String(describing: AppConstants.shared.osVersionString), privacy: .public)")

                if !FileManager.default.fileExists(atPath: AppConstants.shared.documentsDirectoryPath.path)
                {
                    AppConstants.shared.logger.info("Documents directory does not exist, creating it...")
                    do
                    {
                        try FileManager.default.createDirectory(at: AppConstants.shared.documentsDirectoryPath, withIntermediateDirectories: true)
                    }
                    catch let documentDirectoryCreationError
                    {
                        AppConstants.shared.logger.error("Failed while creating document directory: \(documentDirectoryCreationError.localizedDescription)")
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("Documents directory exists")
                }

                if !FileManager.default.fileExists(atPath: AppConstants.shared.metadataFilePath.path)
                {
                    AppConstants.shared.logger.info("Metadata file does not exist, creating it...")

                    do
                    {
                        try Data().write(to: AppConstants.shared.metadataFilePath, options: .atomic)
                    }
                    catch let metadataDirectoryCreationError
                    {
                        AppConstants.shared.logger.error("Failed while creating metadata directory: \(metadataDirectoryCreationError.localizedDescription)")
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("Metadata file exists")
                }
            }
    }
}

private extension View
{
    func packageLoadingTask(of view: ContentView) -> some View
    {
        self
            .task(priority: .high)
            {
                AppConstants.shared.logger.info("Started Package Load startup action at \(Date())")

                defer
                {
                    view.appState.isLoadingFormulae = false
                    view.appState.isLoadingCasks = false
                }

                async let availableFormulae: BrewPackages? = await view.brewData.loadInstalledPackages(packageTypeToLoad: .formula, appState: view.appState)
                async let availableCasks: BrewPackages? = await view.brewData.loadInstalledPackages(packageTypeToLoad: .cask, appState: view.appState)

                view.brewData.installedFormulae = await availableFormulae ?? .init()
                view.brewData.installedCasks = await availableCasks ?? .init()

                view.cachedDownloadsTracker.assignPackageTypeToCachedDownloads(brewData: view.brewData)

                do
                {
                    view.appState.taggedPackageNames = try loadTaggedIDsFromDisk()

                    AppConstants.shared.logger.info("Tagged packages in appState: \(view.appState.taggedPackageNames)")
                    
                    do
                    {
                        try await view.brewData.applyTags(appState: view.appState)
                    }
                    catch let taggedStateApplicationError as NSError
                    {
                        AppConstants.shared.logger.error("Error while applying tagged state to packages: \(taggedStateApplicationError, privacy: .public)")
                        view.appState.showAlert(errorToShow: .couldNotApplyTaggedStateToPackages)
                    }
                }
                catch let uuidLoadingError as NSError
                {
                    AppConstants.shared.logger.error("Failed while loading UUIDs from file: \(uuidLoadingError, privacy: .public)")
                    view.appState.showAlert(errorToShow: .couldNotApplyTaggedStateToPackages)
                }
            }
    }

    func tapLoadingTask(of view: ContentView) -> some View
    {
        self
            .task
            {
                defer
                {
                    view.appState.isLoadingTaps = false
                }

                async let availableTaps: [BrewTap] = await view.tapData.loadUpTappedTaps()

                do
                {
                    view.tapData.addedTaps = try await availableTaps
                }
                catch let tapLoadingError as TapLoadingError
                {
                    AppConstants.shared.logger.error("Failed while loading taps: \(tapLoadingError.localizedDescription)")

                    view.appState.failedWhileLoadingTaps = true

                    switch tapLoadingError
                    {
                    case .couldNotAccessParentTapFolder(let errorDetails):
                        view.appState.showAlert(errorToShow: .tapLoadingFailedDueToTapParentLocation(localizedDescription: errorDetails))
                    case .couldNotReadTapFolderContents(let errorDetails):
                        view.appState.showAlert(errorToShow: .tapLoadingFailedDueToTapItself(localizedDescription: errorDetails))
                    }
                }
                catch let unimplementedError
                {
                    AppConstants.shared.logger.error("Failed while loading taps: Unimplemented error: \(unimplementedError.localizedDescription)")

                    view.appState.failedWhileLoadingTaps = true
                }
            }
    }

    func analyticsSetupTask(of view: ContentView) -> some View
    {
        self
            .task
            {
                AppConstants.shared.logger.info("Started Analytics startup action at \(Date())")

                async let analyticsQueryCommand: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["analytics"])

                if await analyticsQueryCommand.standardOutput.localizedCaseInsensitiveContains("Analytics are enabled")
                {
                    view.allowBrewAnalytics = true
                    AppConstants.shared.logger.info("Analytics are ENABLED")
                }
                else
                {
                    view.allowBrewAnalytics = false
                    AppConstants.shared.logger.info("Analytics are DISABLED")
                }
            }
    }

    func discoverabilitySetupTask(of view: ContentView) -> some View
    {
        self
            .task
            {
                AppConstants.shared.logger.info("Started Discoverability startup action at \(Date())")

                if view.enableDiscoverability
                {
                    if view.appState.isLoadingFormulae && view.appState.isLoadingCasks || view.tapData.addedTaps.isEmpty
                    {
                        await view.loadTopPackages()
                    }
                }
            }
    }

    func cachedDownloadsCalculationTask(of view: ContentView) -> some View
    {
        self
            .task
            {
                if view.cachedDownloadsTracker.cachedDownloads.isEmpty
                {
                    AppConstants.shared.logger.info("Will calculate cached downloads")
                    await view.cachedDownloadsTracker.loadCachedDownloadedPackages(brewData: view.brewData)
                }
            }
    }
}

private extension View
{
    func onChanges(boundToView view: ContentView) -> some View
    {
        self
            .onChange(of: view.cachedDownloadsTracker.cachedDownloadsSize)
            { _ in
                #warning("FIXME: This might fuck up the memory")
                Task
                {
                    AppConstants.shared.logger.info("Will recalculate cached downloads")
                    await view.cachedDownloadsTracker.loadCachedDownloadedPackages(brewData: view.brewData)
                }
            }
            .onChange(of: view.areNotificationsEnabled, perform: { newValue in
                if newValue == true
                {
                    Task
                    {
                        await view.appState.setupNotifications()
                    }
                }
            })
            .onChange(of: view.enableDiscoverability, perform: { newValue in
                if newValue == true
                {
                    Task
                    {
                        await view.loadTopPackages()
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("Will purge top package trackers")
                    /// Clear out the package trackers so they don't take up RAM
                    view.topPackagesTracker.topFormulae = .init()
                    view.topPackagesTracker.topCasks = .init()

                    AppConstants.shared.logger.info("Package tracker status: \(view.topPackagesTracker.topFormulae) \(view.topPackagesTracker.topCasks)")
                }
            })
            .onChange(of: view.discoverabilityDaySpan, perform: { _ in
                Task
                {
                    await view.loadTopPackages()
                }
            })
            .onChange(of: view.customHomebrewPath, perform: { _ in
                restartApp()
            })
            .onChange(of: view.appState.taggedPackageNames) { _ in
                AppConstants.shared.logger.info("Will try to save tagged IDs to disk")
                do
                {
                    try saveTaggedIDsToDisk(appState: view.appState)
                }
                catch let dataSavingError as NSError
                {
                    AppConstants.shared.logger.error("Failed while trying to save data to disk: \(dataSavingError, privacy: .public)")
                }
            }
    }
}

private extension View
{
    /// Various sheets
    func sheets(of view: ContentView) -> some View
    {
        self
            .sheet(item: view.$appState.sheetToShow)
            { sheetType in
                switch sheetType
                {
                case .packageInstallation:
                    AddFormulaView()
                case .tapAddition:
                    AddTapView()

                case .fullUpdate:
                    UpdatePackagesView()

                case .partialUpdate:
                    UpdateSomePackagesView()

                case .corruptedPackageFix(let corruptedPackage):
                    ReinstallCorruptedPackageView(corruptedPackageToReinstall: corruptedPackage)

                case .sudoRequiredForPackageRemoval:
                    SudoRequiredForRemovalSheet()

                case .brewfileExport:
                    BrewfileExportProgressView()

                case .brewfileImport:
                    BrewfileImportProgressView()
                    
                case .maintenance(let fastCacheDeletion):
                    switch fastCacheDeletion
                    {
                    case false:
                        MaintenanceView()
                    case true:
                        MaintenanceView(shouldPurgeCache: false, shouldUninstallOrphans: false, shouldPerformHealthCheck: false, forcedOptions: true)
                    }
                }
            }
    }
}

private extension View
{
    func alerts(of view: ContentView) -> some View
    {
        self
            .alert(isPresented: view.$appState.isShowingFatalError, error: view.appState.fatalAlertType)
            { error in
                switch error
                {
                case .couldNotGetContentsOfPackageFolder:
                    EmptyView()

                case .uninstallationNotPossibleDueToDependency:
                    EmptyView()

                case .couldNotLoadAnyPackages:
                    RestartCorkButton()

                case .triedToThreatFolderContainingPackagesAsPackage:
                    RestartCorkButton()

                case .couldNotLoadCertainPackage(let offendingPackage, let offendingPackageURL, _):
                    VStack
                    {
                        Button
                        {
                            offendingPackageURL.revealInFinder(.openParentDirectoryAndHighlightTarget)
                        } label: {
                            Text("action.reveal-certain-file-in-finder-\(offendingPackage)")
                        }
                        RestartCorkButton()
                    }

                case .licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly:
                    EmptyView()

                case .licenseCheckingFailedDueToNoInternet:
                    EmptyView()

                case .licenseCheckingFailedDueToTimeout:
                    EmptyView()

                case .licenseCheckingFailedForOtherReason:
                    EmptyView()

                case .customBrewExcutableGotDeleted:
                    Button
                    {
                        view.customHomebrewPath = ""
                    } label: {
                        Text("action.reset-custom-brew-executable")
                    }

                case .couldNotFindPackageUUIDInList:
                    EmptyView()

                case .couldNotApplyTaggedStateToPackages:
                    VStack
                    {
                        Button(role: .destructive)
                        {
                            if FileManager.default.fileExists(atPath: AppConstants.shared.documentsDirectoryPath.path)
                            {
                                do
                                {
                                    try FileManager.default.removeItem(atPath: AppConstants.shared.documentsDirectoryPath.path)
                                    restartApp()
                                }
                                catch
                                {
                                    view.appState.fatalAlertType = .couldNotClearMetadata
                                }
                            }
                            else
                            {
                                view.appState.fatalAlertType = .metadataFolderDoesNotExist
                            }
                        } label: {
                            Text("action.clear-metadata")
                        }

                        QuitCorkButton()
                    }

                case .couldNotClearMetadata:
                    VStack
                    {
                        Button
                        {
                            if FileManager.default.fileExists(atPath: AppConstants.shared.documentsDirectoryPath.path)
                            {
                                AppConstants.shared.documentsDirectoryPath.revealInFinder(.openParentDirectoryAndHighlightTarget)
                            }
                            else
                            {
                                view.appState.fatalAlertType = .metadataFolderDoesNotExist
                            }
                        } label: {
                            Text("action.reveal-in-finder")
                        }

                        QuitCorkButton()
                    }

                case .metadataFolderDoesNotExist:
                    QuitCorkButton()

                case .couldNotCreateCorkMetadataDirectory:
                    RestartCorkButton()

                case .couldNotCreateCorkMetadataFile:
                    RestartCorkButton()

                case .installedPackageHasNoVersions(let corruptedPackageName):
                    Button
                    {
                        view.corruptedPackage = .init(name: corruptedPackageName)
                    } label: {
                        Text("action.repair-\(corruptedPackageName)")
                    }

                case .installedPackageIsNotAFolder(let itemName, let itemURL):
                    VStack
                    {
                        Button
                        {
                            itemURL.revealInFinder(.openParentDirectoryAndHighlightTarget)
                        } label: {
                            Text("action.reveal-certain-file-in-finder-\(itemName)")
                        }
                        RestartCorkButton()
                    }

                case .homePathNotSet:
                    QuitCorkButton()

                case .numberOfLoadedPackagesDoesNotMatchNumberOfPackageFolders:
                    EmptyView()

                case .couldNotObtainNotificationPermissions:
                    Button
                    {
                        view.appState.dismissAlert()
                    } label: {
                        Text("action.use-without-notifications")
                    }

                case .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled:
                    EmptyView()

                case .couldNotParseTopPackages:
                    EmptyView()

                case .receivedInvalidResponseFromBrew:
                    Button
                    {
                        view.appState.dismissAlert()
                        view.enableDiscoverability = false
                    } label: {
                        Text("action.close")
                    }

                case .topPackageArrayFilterCouldNotRetrieveAnyPackages:
                    VStack
                    {
                        Button
                        {
                            view.appState.dismissAlert()
                        } label: {
                            Text("action.close")
                        }
                        RestartCorkButton()
                    }

                case .couldNotAssociateAnyPackageWithProvidedPackageUUID:
                    EmptyView()

                case .couldNotFindPackageInParentDirectory:
                    EmptyView()

                case .fatalPackageInstallationError:
                    EmptyView()

                case .fatalPackageUninstallationError:
                    EmptyView()

                case .couldNotSynchronizePackages:
                    RestartCorkButton()

                case .couldNotGetWorkingDirectory:
                    EmptyView()

                case .couldNotDumpBrewfile:
                    EmptyView()

                case .couldNotReadBrewfile:
                    EmptyView()

                case .couldNotGetBrewfileLocation:
                    EmptyView()

                case .couldNotImportBrewfile:
                    EmptyView()

                case .malformedBrewfile:
                    EmptyView()

                case .tapLoadingFailedDueToTapParentLocation:
                    EmptyView()

                case .tapLoadingFailedDueToTapItself:
                    EmptyView()
                case .couldNotDeleteCachedDownloads:
                    EmptyView()
                }
            } message: { error in
                if let recoverySuggestion = error.recoverySuggestion
                {
                    Text(recoverySuggestion)
                }
            }
    }
}

private extension View
{
    func confirmationDialogs(of view: ContentView) -> some View
    {
        self
            .confirmationDialog(view.appState.confirmationDialogType?.title ?? "error.generic", isPresented: view.$appState.isShowingConfirmationDialog, presenting: view.appState.confirmationDialogType, actions: { dialogType in
                switch dialogType
                {
                case .uninstallPackage(let packageToUninstall):
                    AsyncButton
                    {
                        try await view.brewData.uninstallSelectedPackage(
                            package: packageToUninstall,
                            cachedPackagesTracker: view.cachedDownloadsTracker,
                            appState: view.appState,
                            outdatedPackageTracker: view.outdatedPackageTracker,
                            shouldRemoveAllAssociatedFiles: false
                        )
                    } label: {
                        Text("action.uninstall-\(packageToUninstall.name)")
                    }
                    .keyboardShortcut(.defaultAction)
                    .asyncButtonStyle(.plainStyle)
                    
                case .purgePackage(let packageToPurge):
                    AsyncButton
                    {
                        try await view.brewData.uninstallSelectedPackage(
                            package: packageToPurge,
                            cachedPackagesTracker: view.cachedDownloadsTracker,
                            appState: view.appState,
                            outdatedPackageTracker: view.outdatedPackageTracker,
                            shouldRemoveAllAssociatedFiles: true
                        )
                    } label: {
                        Text("action.purge-\(packageToPurge.name)")
                    }
                }
            }, message: { dialogType in
                Text(dialogType.message)
            })
    }
}

private extension View
{
    func topPackagesLoadingTask(of view: ContentView) -> some View
    {
        self
            .task
            {
                await view.loadTopPackages()
            }
    }
}

// MARK: - Functions

private extension ContentView
{
    func loadTopPackages() async
    {
        AppConstants.shared.logger.info("Initial setup finished, time to fetch the top packages")

        defer
        {
            self.appState.isLoadingTopPackages = false
        }

        await self.topPackagesTracker.loadTopPackages(numberOfDays: self.discoverabilityDaySpan.rawValue, appState: self.appState)
    }
}
