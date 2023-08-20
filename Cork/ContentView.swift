//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .none
    @AppStorage("allowBrewAnalytics") var allowBrewAnalytics: Bool = true

    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge

    @AppStorage("enableDiscoverability") var enableDiscoverability: Bool = false
    @AppStorage("discoverabilityDaySpan") var discoverabilityDaySpan: DiscoverabilityDaySpans = .month
    @AppStorage("sortTopPackagesBy") var sortTopPackagesBy: TopPackageSorting = .mostDownloads

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

    @EnvironmentObject var topPackagesTracker: TopPackagesTracker

    @EnvironmentObject var selectedPackageInfo: SelectedPackageInfo

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @State private var multiSelection = Set<UUID>()

    var body: some View
    {
        VStack
        {
            NavigationView
            {
                SidebarView()

                StartPage()
                    .frame(minWidth: 600, minHeight: 500)
            }
            .navigationTitle("app-name")
            .navigationSubtitle(String.localizedPluralString("navigation.installed-packages.count", brewData.installedFormulae.count + brewData.installedCasks.count))
            .toolbar
            {
                ToolbarItemGroup(placement: .primaryAction)
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

                    Spacer()

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
            }
        }
        .onAppear
        {
            print("Brew executable path: \(AppConstants.brewExecutablePath.absoluteString)")

            print("Documents directory: \(AppConstants.documentsDirectoryPath.path)")

            if !FileManager.default.fileExists(atPath: AppConstants.documentsDirectoryPath.path)
            {
                print("Documents directory does not exist, creating it...")
                try! FileManager.default.createDirectory(at: AppConstants.documentsDirectoryPath, withIntermediateDirectories: true)
            }
            else
            {
                print("Documents directory exists")
            }

            if !FileManager.default.fileExists(atPath: AppConstants.metadataFilePath.path)
            {
                print("Metadata file does not exist, creating it...")
                try! Data().write(to: AppConstants.metadataFilePath, options: .atomic)
            }
            else
            {
                print("Metadata file exists")
            }

            Task
            {
                async let analyticsQueryCommand = await shell(AppConstants.brewExecutablePath.absoluteString, ["analytics"])

                brewData.installedFormulae = await loadUpFormulae(appState: appState, sortBy: sortPackagesBy)
                brewData.installedCasks = await loadUpCasks(appState: appState, sortBy: sortPackagesBy)

                availableTaps.addedTaps = await loadUpTappedTaps()

                do
                {
                    appState.taggedPackageNames = try loadTaggedIDsFromDisk()

                    print("Tagged packages in appState: \(appState.taggedPackageNames)")

                    do
                    {
                        try await applyTagsToPackageTrackingArray(appState: appState, brewData: brewData)
                    }
                    catch let taggedStateApplicationError as NSError
                    {
                        print("Error while applying tagged state to packages: \(taggedStateApplicationError)")
                        appState.fatalAlertType = .couldNotApplyTaggedStateToPackages
                        appState.isShowingFatalError = true
                    }
                }
                catch let uuidLoadingError as NSError
                {
                    print("Failed while loading UUIDs from file: \(uuidLoadingError)")
                    appState.fatalAlertType = .couldNotApplyTaggedStateToPackages
                    appState.isShowingFatalError = true
                }

                if await analyticsQueryCommand.standardOutput.contains("Analytics are enabled")
                {
                    allowBrewAnalytics = true
                    print("Analytics are ENABLED")
                }
                else
                {
                    allowBrewAnalytics = false
                    print("Analytics are DISABLED")
                }
            }
        }
        .task(priority: .background)
        {
            if enableDiscoverability
            {
                if appState.isLoadingFormulae && appState.isLoadingCasks || availableTaps.addedTaps.isEmpty
                {
                    await loadTopPackages()
                }
            }
        }
        .onChange(of: sortPackagesBy, perform: { newSortOption in
            switch newSortOption
            {
            case .none:
                print("Chose NONE")

            case .alphabetically:
                print("Chose ALPHABETICALLY")
                brewData.installedFormulae = sortPackagesAlphabetically(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesAlphabetically(brewData.installedCasks)

            case .byInstallDate:
                print("Chose BY INSTALL DATE")
                brewData.installedFormulae = sortPackagesByInstallDate(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesByInstallDate(brewData.installedCasks)

            case .bySize:
                print("Chose BY SIZE")
                brewData.installedFormulae = sortPackagesBySize(brewData.installedFormulae)
                brewData.installedCasks = sortPackagesBySize(brewData.installedCasks)
            }
        })
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
                print("Will purge top package trackers")
                /// Clear out the package trackers so they don't take up RAM
                topPackagesTracker.topFormulae = .init()
                topPackagesTracker.topCasks = .init()

                print("Package tracker status: \(topPackagesTracker.topFormulae) \(topPackagesTracker.topCasks)")
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
        .sheet(isPresented: $appState.isShowingInstallationSheet)
        {
            AddFormulaView(isShowingSheet: $appState.isShowingInstallationSheet, packageInstallationProcessStep: .ready)
        }
        .sheet(isPresented: $appState.isShowingPackageReinstallationSheet)
        {
            ReinstallCorruptedPackageView(corruptedPackageToReinstall: appState.corruptedPackage)
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
            }
        })
    }

    func loadTopPackages() async -> Void
    {
        print("Initial setup finished, time to fetch the top packages")

        do
        {
            appState.isLoadingTopPackages = true

            async let topFormulae: [TopPackage] = try await loadUpTopPackages(numberOfDays: discoverabilityDaySpan.rawValue, isCask: false, appState: appState)
            async let topCasks: [TopPackage] = try await loadUpTopPackages(numberOfDays: discoverabilityDaySpan.rawValue, isCask: true, appState: appState)

            topPackagesTracker.topFormulae = try await topFormulae
            topPackagesTracker.topCasks = try await topCasks

            print("Packages in formulae tracker: \(topPackagesTracker.topFormulae.count)")
            print("Packages in cask tracker: \(topPackagesTracker.topCasks.count)")
            
            sortTopPackages()
            
            appState.isLoadingTopPackages = false
        }
        catch let topPackageLoadingError
        {
            print("Failed while loading top packages: \(topPackageLoadingError)")

            if topPackageLoadingError is DataDownloadingError
            {
                appState.fatalAlertType = .receivedInvalidResponseFromBrew
                appState.isShowingFatalError = true
            }
        }
    }
    private func sortTopPackages() -> Void
    {
        switch sortTopPackagesBy
        {
            case .mostDownloads:
                
                print("Will sort top packages by most downloads")
                
                topPackagesTracker.topFormulae = topPackagesTracker.topFormulae.sorted(by: { $0.packageDownloads > $1.packageDownloads })
                topPackagesTracker.topCasks = topPackagesTracker.topCasks.sorted(by: { $0.packageDownloads > $1.packageDownloads })
                
            case .fewestDownloads:
                
                print("Will sort top packages by fewest downloads")
                
                topPackagesTracker.topFormulae = topPackagesTracker.topFormulae.sorted(by: { $0.packageDownloads < $1.packageDownloads })
                topPackagesTracker.topCasks = topPackagesTracker.topCasks.sorted(by: { $0.packageDownloads < $1.packageDownloads })
                
            case .random:
                
                print("Will sort top packages randomly")
                
                topPackagesTracker.topFormulae = topPackagesTracker.topFormulae.shuffled()
                topPackagesTracker.topCasks = topPackagesTracker.topCasks.shuffled()
        }
    }
}
