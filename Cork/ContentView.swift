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

    @ViewBuilder private var manageServicesButton: some View
    {
        Button
        {
            openWindow(id: .servicesWindowID)
        } label: {
            Label("navigation.manage-services", systemImage: "square.stack.3d.down.right")
        }
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

            async let availableTaps = await loadUpTappedTaps()

            brewData.installedFormulae = await availableFormulae
            brewData.installedCasks = await availableCasks

            tapData.addedTaps = await availableTaps
            
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
        .onChange(of: sortTopPackagesBy, perform: { _ in
            sortTopPackages()
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
        .alert(isPresented: $appState.isShowingFatalError, content: {
            switch appState.fatalAlertType
            {
            case let .uninstallationNotPossibleDueToDependency(packageThatTheUserIsTryingToUninstall):
                return Alert(
                    title: Text("alert.unable-to-uninstall-\(packageThatTheUserIsTryingToUninstall.name).title"),
                    message: Text("alert.unable-to-uninstall-dependency.message-\(appState.offendingDependencyProhibitingUninstallation)-\(packageThatTheUserIsTryingToUninstall.name)"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )

            case .couldNotApplyTaggedStateToPackages:
                return Alert(
                    title: Text("alert.could-not-apply-tags.title"),
                    message: Text("alert.could-not-apply-tags.message"),
                    primaryButton: .cancel(Text("action.quit"), action: {
                        NSApplication.shared.terminate(self)
                    }),
                    secondaryButton: .destructive(Text("action.clear-metadata"), action: {
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
                    })
                )

            case .couldNotClearMetadata:
                return Alert(
                    title: Text("alert.could-not-clear-metadata.title"),
                    message: Text("alert.could-not-clear-metadata.message"),
                    primaryButton: .cancel(Text("action.restart"), action: {
                        restartApp()
                    }),
                    secondaryButton: .default(Text("action.reveal-in-finder"), action: {
                        if FileManager.default.fileExists(atPath: AppConstants.documentsDirectoryPath.path)
                        {
                            AppConstants.documentsDirectoryPath.revealInFinder(.openParentDirectoryAndHighlightTarget)
                        }
                        else
                        {
                            appState.fatalAlertType = .metadataFolderDoesNotExist
                        }
                    })
                )

            case .metadataFolderDoesNotExist:
                return Alert(
                    title: Text("alert.metadata-folder-does-not-exist.title"),
                    message: Text("alert.metadata-folder-does-not-exist.message"),
                    dismissButton: .default(Text("action.quit"), action: {
                        NSApplication.shared.terminate(self)
                    })
                )

            case .couldNotCreateCorkMetadataDirectory:
                return Alert(
                    title: Text("alert.could-not-create-metadata-directory.title"),
                    message: Text("alert.could-not-create-metadata-directory-or-folder.message"),
                    dismissButton: .default(Text("action.restart"), action: {
                        restartApp()
                    })
                )
            case .couldNotCreateCorkMetadataFile:
                return Alert(
                    title: Text("alert.could-not-create-metadata-file.title"),
                    message: Text("alert.could-not-create-metadata-directory-or-folder.message"),
                    dismissButton: .default(Text("action.restart"), action: {
                        restartApp()
                    })
                )
            case let .installedPackageHasNoVersions(corruptedPackageName):
                return Alert(
                    title: Text("alert.package-corrupted.title-\(corruptedPackageName)"),
                    message: Text("alert.package-corrupted.message"),
                    dismissButton: .default(Text("action.repair-\(corruptedPackageName)"), action: {
                        self.corruptedPackage = .init(name: corruptedPackageName)
                    })
                )
            case .homePathNotSet:
                return Alert(
                    title: Text("alert.home-not-set.title"),
                    message: Text("alert.home-not-set.message"),
                    dismissButton: .destructive(Text("action.quit"), action: {
                        exit(0)
                    })
                )
            case .couldNotObtainNotificationPermissions:
                return Alert(
                    title: Text("alert.notifications-error-while-obtaining-permissions.title"),
                    message: Text("alert.notifications-error-while-obtaining-permissions.message"),
                    dismissButton: .cancel(Text("action.use-without-notifications"), action: {
                        appState.dismissAlert()
                    })
                )
            case .couldNotParseTopPackages:
                return Alert(
                    title: Text("alert.notifications-error-while-parsing-top-packages.title"),
                    message: Text("alert.notifications-error-while-parsing-top-packages.message"),
                    dismissButton: .cancel(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )
            case .receivedInvalidResponseFromBrew:
                return Alert(
                    title: Text("alert.notifications-error-while-getting-top-packages.title"),
                    message: Text("alert.notifications-error-while-getting-top-package.message"),
                    dismissButton: .cancel(Text("action.close"), action: {
                        appState.dismissAlert()
                        enableDiscoverability = false
                    })
                )
            case .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled:
                return Alert(
                    title: Text("sidebar.section.added-taps.remove.title-\(appState.offendingTapProhibitingRemovalOfTap)"),
                    message: Text("alert.notification-could-not-remove-tap-due-to-packages-from-it-still-being-installed.message-\(appState.offendingTapProhibitingRemovalOfTap)"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingRemoveTapFailedAlert = false
                    })
                )

            case .topPackageArrayFilterCouldNotRetrieveAnyPackages:
                return Alert(
                    title: Text("alert.top-package-retrieval-function-turned-up-empty.title"),
                    message: Text("alert.top-package-retrieval-function-turned-up-empty.message"),
                    primaryButton: .default(Text("action.close"), action: {
                        appState.isShowingRemoveTapFailedAlert = false
                    }),
                    secondaryButton: .destructive(Text("action.restart"), action: {
                        restartApp()
                    })
                )
            case .couldNotAssociateAnyPackageWithProvidedPackageUUID:
                return Alert(
                    title: Text("alert.could-not-associate-any-package-in-tracker-with-provided-uuid.title"),
                    message: Text("alert.could-not-associate-any-package-in-tracker-with-provided-uuid.message"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )

            case .couldNotFindPackageInParentDirectory:
                return Alert(
                    title: Text("alert.could-not-find-package-in-parent-directory.title"),
                    message: Text("message.try-again-or-restart"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )

            case .couldNotGetWorkingDirectory:
                return Alert(
                    title: Text("alert.could-not-get-brewfile-working-directory.title"),
                    message: Text("message.try-again-or-restart"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )
            case .couldNotDumpBrewfile(let error):
                return Alert(
                    title: Text("alert.could-not-dump-brewfile.title"),
                    message: Text("message.try-again-or-restart-\(error)"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )

            case .couldNotReadBrewfile:
                return Alert(
                    title: Text("alert.could-not-read-brewfile.title"),
                    message: Text("message.try-again-or-restart"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )
            case .couldNotGetBrewfileLocation:
                return Alert(
                    title: Text("alert.could-not-get-brewfile-location.title"),
                    message: Text("alert.could-not-get-brewfile-location.message"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )
            case .couldNotImportBrewfile:
                return Alert(
                    title: Text("alert.could-not-import-brewfile.title"),
                    message: Text("alert.could-not-import-brewfile.message"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )
            case .malformedBrewfile:
                return Alert(
                    title: Text("alert.malformed-brewfile.title"),
                    message: Text("alert.malformed-brewfile.message"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )
            case let .fatalPackageInstallationError(errorDetails):
                return Alert(
                    title: Text("alert.fatal-installation.error"),
                    message: Text(errorDetails),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.dismissAlert()
                    })
                )
            case .customBrewExcutableGotDeleted:
                return Alert(
                    title: Text("alert.fatal.custom-brew-executable-deleted.title"),
                    dismissButton: .default(Text("action.reset-custom-brew-executable"), action: {
                        customHomebrewPath = ""
                    })
                )
            case .licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly:
                return Alert(
                    title: Text("alert.fatal.license-checking.could-not-encode-authorization-complex.title"),
                    message: Text("alert.fatal.license-checking.could-not-encode-authorization-complex.message")
                )
            case .couldNotSynchronizePackages:
                return Alert(
                    title: Text("alert.fatal.could-not-synchronize-packages.title"),
                    dismissButton: .default(Text("action.restart"), action: {
                        restartApp()
                    })
                )
            case let .couldNotLoadAnyPackages(error):
                return Alert(
                    title: Text("alert.fatal.could-not-load-any-packages-\(error.localizedDescription).title"),
                    message: Text("alert.restart-or-reinstall"),
                    dismissButton: .default(Text("action.restart"), action: {
                        restartApp()
                    })
                )
            case let .couldNotLoadCertainPackage(offendingPackage):
                return Alert(
                    title: Text("alert.fatal-\(offendingPackage)-prevented-loading.title"),
                    dismissButton: .default(Text("action.restart"), action: {
                        restartApp()
                    })
                )
            }
        })
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

        do
        {
            appState.isLoadingTopPackages = true

            async let topFormulae: [TopPackage] = try await loadUpTopPackages(numberOfDays: discoverabilityDaySpan.rawValue, isCask: false, appState: appState)
            async let topCasks: [TopPackage] = try await loadUpTopPackages(numberOfDays: discoverabilityDaySpan.rawValue, isCask: true, appState: appState)

            topPackagesTracker.topFormulae = try await topFormulae
            topPackagesTracker.topCasks = try await topCasks

            AppConstants.logger.info("Packages in formulae tracker: \(topPackagesTracker.topFormulae.count)")
            AppConstants.logger.info("Packages in cask tracker: \(topPackagesTracker.topCasks.count)")

            sortTopPackages()

            appState.isLoadingTopPackages = false
        }
        catch let topPackageLoadingError
        {
            AppConstants.logger.error("Failed while loading top packages: \(topPackageLoadingError, privacy: .public)")

            if topPackageLoadingError is DataDownloadingError
            {
                appState.showAlert(errorToShow: .receivedInvalidResponseFromBrew)
            }
            else
            {
                appState.failedWhileLoadingTopPackages = true
            }
        }
    }

    private func sortTopPackages()
    {
        switch sortTopPackagesBy
        {
        case .mostDownloads:

            AppConstants.logger.info("Will sort top packages by most downloads")

            topPackagesTracker.topFormulae = topPackagesTracker.topFormulae.sorted(by: { $0.packageDownloads > $1.packageDownloads })
            topPackagesTracker.topCasks = topPackagesTracker.topCasks.sorted(by: { $0.packageDownloads > $1.packageDownloads })

        case .fewestDownloads:

            AppConstants.logger.info("Will sort top packages by fewest downloads")

            topPackagesTracker.topFormulae = topPackagesTracker.topFormulae.sorted(by: { $0.packageDownloads < $1.packageDownloads })
            topPackagesTracker.topCasks = topPackagesTracker.topCasks.sorted(by: { $0.packageDownloads < $1.packageDownloads })

        case .random:

            AppConstants.logger.info("Will sort top packages randomly")

            topPackagesTracker.topFormulae = topPackagesTracker.topFormulae.shuffled()
            topPackagesTracker.topCasks = topPackagesTracker.topCasks.shuffled()
        }
    }
}
