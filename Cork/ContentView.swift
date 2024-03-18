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

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var tapData: AvailableTaps

    @EnvironmentObject var topPackagesTracker: TopPackagesTracker

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @State private var multiSelection = Set<UUID>()
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

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

                ToolbarItem(id: "addTap", placement: .primaryAction)
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

                ToolbarItem(id: "installPackage", placement: .primaryAction)
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
                appState.fatalAlertType = .customBrewExcutableGotDeleted
                appState.isShowingFatalError = true
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
                    appState.fatalAlertType = .couldNotApplyTaggedStateToPackages
                    appState.isShowingFatalError = true
                }
            }
            catch let uuidLoadingError as NSError
            {
                AppConstants.logger.error("Failed while loading UUIDs from file: \(uuidLoadingError, privacy: .public)")
                appState.fatalAlertType = .couldNotApplyTaggedStateToPackages
                appState.isShowingFatalError = true
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
            }
        }
        .onChange(of: appState.cachedDownloadsFolderSize)
        { _ in
            Task(priority: .background)
            {
                AppConstants.logger.info("Will recalculate cached downloads")
                appState.cachedDownloads = .init()
                await appState.loadCachedDownloadedPackages()
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
            AddFormulaView(isShowingSheet: $appState.isShowingInstallationSheet, packageInstallationProcessStep: .ready)
        }
        .sheet(isPresented: $appState.isShowingPackageReinstallationSheet)
        {
            ReinstallCorruptedPackageView(corruptedPackageToReinstall: appState.corruptedPackage)
        }
        .sheet(isPresented: $appState.isShowingSudoRequiredForUninstallSheet)
        {
            SudoRequiredForRemovalSheet(isShowingSheet: $appState.isShowingSudoRequiredForUninstallSheet)
        }
        .sheet(isPresented: $appState.isShowingAddTapSheet)
        {
            AddTapView(isShowingSheet: $appState.isShowingAddTapSheet)
        }
        .sheet(isPresented: $appState.isShowingUpdateSheet)
        {
            UpdatePackagesView(isShowingSheet: $appState.isShowingUpdateSheet)
        }
        .sheet(isPresented: $appState.isShowingIncrementalUpdateSheet)
        {
            UpdateSomePackagesView(isShowingSheet: $appState.isShowingIncrementalUpdateSheet)
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
            case .uninstallationNotPossibleDueToDependency:
                return Alert(
                    title: Text("alert.unable-to-uninstall-dependency.title"),
                    message: Text("alert.unable-to-uninstall-dependency.message-\(appState.offendingDependencyProhibitingUninstallation)"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
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
                            NSWorkspace.shared.open(AppConstants.documentsDirectoryPath)
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
            case .installedPackageHasNoVersions:
                return Alert(
                    title: Text("alert.package-corrupted.title-\(appState.corruptedPackage)"),
                    message: Text("alert.package-corrupted.message"),
                    dismissButton: .default(Text("action.repair-\(appState.corruptedPackage)"), action: {
                        appState.isShowingPackageReinstallationSheet = true
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
                        appState.isShowingFatalError = false
                    })
                )
            case .couldNotParseTopPackages:
                return Alert(
                    title: Text("alert.notifications-error-while-parsing-top-packages.title"),
                    message: Text("alert.notifications-error-while-parsing-top-packages.message"),
                    dismissButton: .cancel(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )
            case .receivedInvalidResponseFromBrew:
                return Alert(
                    title: Text("alert.notifications-error-while-getting-top-packages.title"),
                    message: Text("alert.notifications-error-while-getting-top-package.message"),
                    dismissButton: .cancel(Text("action.close"), action: {
                        appState.isShowingFatalError = false
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
                        appState.isShowingFatalError = false
                    })
                )

            case .couldNotFindPackageInParentDirectory:
                return Alert(
                    title: Text("alert.could-not-find-package-in-parent-directory.title"),
                    message: Text("message.try-again-or-restart"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )

            case .couldNotGetWorkingDirectory:
                return Alert(
                    title: Text("alert.could-not-get-brewfile-working-directory.title"),
                    message: Text("message.try-again-or-restart"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )
            case .couldNotDumpBrewfile:
                return Alert(
                    title: Text("alert.could-not-dump-brewfile.title"),
                    message: Text("message.try-again-or-restart"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )

            case .couldNotReadBrewfile:
                return Alert(
                    title: Text("alert.could-not-read-brewfile.title"),
                    message: Text("message.try-again-or-restart"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )
            case .couldNotGetBrewfileLocation:
                return Alert(
                    title: Text("alert.could-not-get-brewfile-location.title"),
                    message: Text("alert.could-not-get-brewfile-location.message"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )
            case .couldNotImportBrewfile:
                return Alert(
                    title: Text("alert.could-not-import-brewfile.title"),
                    message: Text("alert.could-not-import-brewfile.message"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )
            case .malformedBrewfile:
                return Alert(
                    title: Text("alert.malformed-brewfile.title"),
                    message: Text("alert.malformed-brewfile.message"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
                    })
                )
            case .fatalPackageInstallationError:
                return Alert(
                    title: Text("alert.fatal-installation.error"),
                    message: Text(appState.fatalAlertDetails),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingFatalError = false
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
            }
        })
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
                appState.fatalAlertType = .receivedInvalidResponseFromBrew
                appState.isShowingFatalError = true
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
