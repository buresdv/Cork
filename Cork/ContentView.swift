//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View, Sendable
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .byInstallDate
    @AppStorage("allowBrewAnalytics") var allowBrewAnalytics: Bool = true

    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge

    @AppStorage("enableDiscoverability") var enableDiscoverability: Bool = false
    @AppStorage("discoverabilityDaySpan") var discoverabilityDaySpan: DiscoverabilityDaySpans = .month
    @AppStorage("sortTopPackagesBy") var sortTopPackagesBy: TopPackageSorting = .mostDownloads

    @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true

    @AppStorage("customHomebrewPath") var customHomebrewPath: String = ""

    @Environment(\.openWindow) var openWindow

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var tapData: AvailableTaps

    @EnvironmentObject var topPackagesTracker: TopPackagesTracker

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    @EnvironmentObject var uninstallationConfirmationTracker: UninstallationConfirmationTracker

    @State private var multiSelection = Set<UUID>()
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    @State private var corruptedPackage: CorruptedPackage?

    // MARK: - ViewBuilders

    @ViewBuilder private var upgradePackagesButton: some View
    {
        Button
        {
            appState.isShowingUpdateSheet = true
        } label: {
            Label
            {
                Text("navigation.upgrade-packages")
            } icon: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .help("navigation.upgrade-packages.help")
        .disabled(appState.isCheckingForPackageUpdates)
    }

    @ViewBuilder private var addTapButton: some View
    {
        Button
        {
            appState.isShowingAddTapSheet.toggle()
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
            appState.isShowingInstallationSheet.toggle()
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
            appState.isShowingMaintenanceSheet.toggle()
        } label: {
            Label("start-page.open-maintenance", systemImage: "arrow.3.trianglepath")
        }
        .help("navigation.maintenance.help")
    }

    @ViewBuilder private var manageServicesButton: some View
    {
        Button
        {
            openWindow(id: .servicesWindowID)
        } label: {
            Label("navigation.manage-services", systemImage: "square.stack.3d.down.right")
        }
        .help("navigation.manage-services.help")
    }

    // MARK: - The main view

    var body: some View
    {
        VStack
        {
            NavigationSplitView(columnVisibility: $columnVisibility)
            {
                SidebarView()
            } detail: {
                StartPage()
                    .frame(minWidth: 600, minHeight: 500)
            }
            .navigationTitle("app-name")
            .navigationSubtitle("navigation.installed-packages.count-\((displayOnlyIntentionallyInstalledPackagesByDefault ? brewData.installedFormulae.filter(\.installedIntentionally).count : brewData.installedFormulae.count) + brewData.installedCasks.count)")
            .toolbar(id: "PackageActions")
            {
                ToolbarItem(id: "upgradePackages", placement: .primaryAction)
                {
                    upgradePackagesButton
                }

                ToolbarItem(id: "addTap", placement: .primaryAction)
                {
                    addTapButton
                }

                ToolbarItem(id: "installPackage", placement: .primaryAction)
                {
                    installPackageButton
                }

                ToolbarItem(id: "maintenance", placement: .primaryAction)
                {
                    performMaintenanceButton
                }
                .defaultCustomization(.hidden)
                
                ToolbarItem(id: "manageServices", placement: .primaryAction)
                {
                    manageServicesButton
                }
                .defaultCustomization(.hidden)

                ToolbarItem(id: "spacer", placement: .primaryAction)
                {
                    Spacer()
                }
                .defaultCustomization(.hidden)

                ToolbarItem(id: "divider", placement: .primaryAction)
                {
                    Divider()
                }
                .defaultCustomization(.hidden)

                #warning("TODO: Implement this button")
                /*
                 ToolbarItem(id: "installPackageDirectly", placement: .automatic)
                 {
                     Button
                     {
                         AppConstants.logger.info("Ahoj")
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
        }
        .onAppear
        {
            AppConstants.logger.debug("Brew executable path: \(AppConstants.brewExecutablePath, privacy: .public)")

            if !customHomebrewPath.isEmpty && !FileManager.default.fileExists(atPath: AppConstants.brewExecutablePath.path)
            {
                appState.showAlert(errorToShow: .customBrewExcutableGotDeleted)
            }

            AppConstants.logger.debug("Documents directory: \(AppConstants.documentsDirectoryPath.path, privacy: .public)")

            AppConstants.logger.debug("System version: \(String(describing: AppConstants.osVersionString), privacy: .public)")

            if !FileManager.default.fileExists(atPath: AppConstants.documentsDirectoryPath.path)
            {
                AppConstants.logger.info("Documents directory does not exist, creating it...")
                try! FileManager.default.createDirectory(at: AppConstants.documentsDirectoryPath, withIntermediateDirectories: true)
            }
            else
            {
                AppConstants.logger.info("Documents directory exists")
            }

            if !FileManager.default.fileExists(atPath: AppConstants.metadataFilePath.path)
            {
                AppConstants.logger.info("Metadata file does not exist, creating it...")
                try! Data().write(to: AppConstants.metadataFilePath, options: .atomic)
            }
            else
            {
                AppConstants.logger.info("Metadata file exists")
            }
        }
        .task(priority: .high)
        {
            AppConstants.logger.info("Started Package Load startup action at \(Date())")

            defer
            {
                appState.isLoadingFormulae = false
                appState.isLoadingCasks = false
            }

            async let availableFormulae = await loadUpPackages(whatToLoad: .formula, appState: appState)
            async let availableCasks = await loadUpPackages(whatToLoad: .cask, appState: appState)

            brewData.installedFormulae = await availableFormulae
            brewData.installedCasks = await availableCasks
            
            await tapData.loadAddedTaps()

            appState.assignPackageTypeToCachedDownloads(brewData: brewData)

            do
            {
                appState.taggedPackageNames = try loadTaggedIDsFromDisk()

                AppConstants.logger.info("Tagged packages in appState: \(appState.taggedPackageNames)")

                do
                {
                    try await applyTagsToPackageTrackingArray(appState: appState, brewData: brewData)
                }
                catch let taggedStateApplicationError as NSError
                {
                    AppConstants.logger.error("Error while applying tagged state to packages: \(taggedStateApplicationError, privacy: .public)")
                    appState.showAlert(errorToShow: .couldNotApplyTaggedStateToPackages)
                }
            }
            catch let uuidLoadingError as NSError
            {
                AppConstants.logger.error("Failed while loading UUIDs from file: \(uuidLoadingError, privacy: .public)")
                appState.showAlert(errorToShow: .couldNotApplyTaggedStateToPackages)
            }
        }
        .task(priority: .background)
        {
            AppConstants.logger.info("Started Analytics startup action at \(Date())")

            async let analyticsQueryCommand = await shell(AppConstants.brewExecutablePath, ["analytics"])

            if await analyticsQueryCommand.standardOutput.localizedCaseInsensitiveContains("Analytics are enabled")
            {
                allowBrewAnalytics = true
                AppConstants.logger.info("Analytics are ENABLED")
            }
            else
            {
                allowBrewAnalytics = false
                AppConstants.logger.info("Analytics are DISABLED")
            }
        }
        .task(priority: .background)
        {
            AppConstants.logger.info("Started Discoverability startup action at \(Date())")

            if enableDiscoverability
            {
                if appState.isLoadingFormulae && appState.isLoadingCasks || tapData.addedTaps.isEmpty
                {
                    await loadTopPackages()
                }
            }
        }
        .task(priority: .background)
        {
            if appState.cachedDownloads.isEmpty
            {
                AppConstants.logger.info("Will calculate cached downloads")
                await appState.loadCachedDownloadedPackages()
                appState.assignPackageTypeToCachedDownloads(brewData: brewData)
            }
        }
        .onChange(of: appState.cachedDownloadsFolderSize)
        { _ in
            Task(priority: .background)
            {
                AppConstants.logger.info("Will recalculate cached downloads")
                appState.cachedDownloads = .init()
                await appState.loadCachedDownloadedPackages()
                appState.assignPackageTypeToCachedDownloads(brewData: brewData)
            }
        }
        .onChange(of: areNotificationsEnabled, perform: { newValue in
            if newValue == true
            {
                Task(priority: .background)
                {
                    await appState.setupNotifications()
                }
            }
        })
        .onChange(of: enableDiscoverability, perform: { newValue in
            if newValue == true
            {
                Task(priority: .userInitiated)
                {
                    await loadTopPackages()
                }
            }
            else
            {
                AppConstants.logger.info("Will purge top package trackers")
                /// Clear out the package trackers so they don't take up RAM
                topPackagesTracker.topFormulae = .init()
                topPackagesTracker.topCasks = .init()

                AppConstants.logger.info("Package tracker status: \(topPackagesTracker.topFormulae) \(topPackagesTracker.topCasks)")
            }
        })
        .onChange(of: discoverabilityDaySpan, perform: { _ in
            Task(priority: .userInitiated)
            {
                await loadTopPackages()
            }
        })
        .onChange(of: customHomebrewPath, perform: { _ in
            restartApp()
        })
        .sheet(isPresented: $appState.isShowingInstallationSheet)
        {
            AddFormulaView(packageInstallationProcessStep: .ready)
        }
        .sheet(item: $corruptedPackage, onDismiss: {
            corruptedPackage = nil
        }, content: { corruptedPackageInternal in
            ReinstallCorruptedPackageView(corruptedPackageToReinstall: corruptedPackageInternal)
        })
        .sheet(isPresented: $appState.isShowingSudoRequiredForUninstallSheet)
        {
            SudoRequiredForRemovalSheet()
        }
        .sheet(isPresented: $appState.isShowingAddTapSheet)
        {
            AddTapView()
        }
        .sheet(isPresented: $appState.isShowingUpdateSheet)
        {
            UpdatePackagesView()
        }
        .sheet(isPresented: $appState.isShowingIncrementalUpdateSheet)
        {
            UpdateSomePackagesView()
        }
        .sheet(isPresented: $appState.isShowingBrewfileExportProgress)
        {
            BrewfileExportProgressView()
        }
        .sheet(isPresented: $appState.isShowingBrewfileImportProgress)
        {
            BrewfileImportProgressView()
        }
        .alert(isPresented: $appState.isShowingFatalError, error: appState.fatalAlertType)
        { error in
            switch error
            {
            case .uninstallationNotPossibleDueToDependency(let packageThatTheUserIsTryingToUninstall, let offendingDependencyProhibitingUninstallation):
                EmptyView()

            case .couldNotLoadAnyPackages:
                RestartCorkButton()

            case .couldNotLoadCertainPackage(let offendingPackage, let offendingPackageURL):
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
                    customHomebrewPath = ""
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
                        if FileManager.default.fileExists(atPath: AppConstants.documentsDirectoryPath.path)
                        {
                            do
                            {
                                try FileManager.default.removeItem(atPath: AppConstants.documentsDirectoryPath.path)
                                restartApp()
                            }
                            catch
                            {
                                appState.fatalAlertType = .couldNotClearMetadata
                            }
                        }
                        else
                        {
                            appState.fatalAlertType = .metadataFolderDoesNotExist
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
                        if FileManager.default.fileExists(atPath: AppConstants.documentsDirectoryPath.path)
                        {
                            AppConstants.documentsDirectoryPath.revealInFinder(.openParentDirectoryAndHighlightTarget)
                        }
                        else
                        {
                            appState.fatalAlertType = .metadataFolderDoesNotExist
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
                    self.corruptedPackage = .init(name: corruptedPackageName)
                } label: {
                    Text("action.repair-\(corruptedPackageName)")
                }

            case .installedPackageIsNotAFolder(itemName: let itemName, itemURL: let itemURL):
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

            case .couldNotObtainNotificationPermissions:
                Button
                {
                    appState.dismissAlert()
                } label: {
                    Text("action.use-without-notifications")
                }

            case .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(let offendingTapProhibitingRemovalOfTap):
                EmptyView()

            case .couldNotParseTopPackages:
                EmptyView()

            case .receivedInvalidResponseFromBrew:
                Button
                {
                    appState.dismissAlert()
                    enableDiscoverability = false
                } label: {
                    Text("action.close")
                }

            case .topPackageArrayFilterCouldNotRetrieveAnyPackages:
                VStack
                {
                    Button
                    {
                        appState.dismissAlert()
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

            case .couldNotSynchronizePackages:
                RestartCorkButton()

            case .couldNotGetWorkingDirectory:
                EmptyView()

            case .couldNotDumpBrewfile(error: let error):
                EmptyView()

            case .couldNotReadBrewfile:
                EmptyView()

            case .couldNotGetBrewfileLocation:
                EmptyView()

            case .couldNotImportBrewfile:
                EmptyView()

            case .malformedBrewfile:
                EmptyView()
            }
        } message: { error in
            if let recoverySuggestion = error.recoverySuggestion
            {
                Text(recoverySuggestion)
            }
        }
        .confirmationDialog(uninstallationConfirmationTracker.shouldPurge ? "action.purge.confirm.title.\(uninstallationConfirmationTracker.packageThatNeedsConfirmation.name)" : "action.uninstall.confirm.title.\(uninstallationConfirmationTracker.packageThatNeedsConfirmation.name)", isPresented: $uninstallationConfirmationTracker.isShowingUninstallOrPurgeConfirmation)
        {
            Button(role: .destructive)
            {
                uninstallationConfirmationTracker.isShowingUninstallOrPurgeConfirmation = false

                Task
                {
                    try await brewData.uninstallSelectedPackage(
                        package: uninstallationConfirmationTracker.packageThatNeedsConfirmation,
                        appState: appState,
                        outdatedPackageTracker: outdatedPackageTracker,
                        shouldRemoveAllAssociatedFiles: uninstallationConfirmationTracker.shouldPurge,
                        shouldApplyUninstallSpinnerToRelevantItemInSidebar: uninstallationConfirmationTracker.isCalledFromSidebar
                    )
                }
            } label: {
                Text(uninstallationConfirmationTracker.shouldPurge ? "action.purge-\(uninstallationConfirmationTracker.packageThatNeedsConfirmation.name)" : "action.uninstall-\(uninstallationConfirmationTracker.packageThatNeedsConfirmation.name)")
            }
            .keyboardShortcut(.defaultAction)

            Button(role: .cancel)
            {
                uninstallationConfirmationTracker.dismissConfirmationDialog()
            } label: {
                Text("action.cancel")
            }
            .keyboardShortcut(.cancelAction)
        } message: {
            Text("action.warning.cannot-be-undone")
        }
    }

    func loadTopPackages() async
    {
        AppConstants.logger.info("Initial setup finished, time to fetch the top packages")

        defer
        {
            appState.isLoadingTopPackages = false
        }
        
        await topPackagesTracker.loadTopPackages(numberOfDays: discoverabilityDaySpan.rawValue, appState: appState)
    }
}
