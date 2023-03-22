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

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

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
            .navigationSubtitle("navigation.installed-packages.count-\(brewData.installedFormulae.count + brewData.installedCasks.count)")
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
        .onDisappear
        {
            print("Will die...")
            do
            {
                try saveTaggedIDsToDisk(appState: appState)
            }
            catch let dataSavingError as NSError
            {
                print("Failed while trying to save data to disk: \(dataSavingError)")
            }
            print("Died")
        }
        .sheet(isPresented: $appState.isShowingInstallationSheet)
        {
            AddFormulaView(isShowingSheet: $appState.isShowingInstallationSheet)
        }
        .sheet(isPresented: $appState.isShowingAddTapSheet)
        {
            AddTapView(isShowingSheet: $appState.isShowingAddTapSheet)
        }
        .sheet(isPresented: $appState.isShowingUpdateSheet)
        {
            UpdatePackagesView(isShowingSheet: $appState.isShowingUpdateSheet)
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
                    }))
            case .couldNotCreateCorkMetadataFile:
                    return Alert(
                        title: Text("alert.could-not-create-metadata-file.title"),
                        message: Text("alert.could-not-create-metadata-directory-or-folder.message"),
                        dismissButton: .default(Text("action.restart"), action: {
                        restartApp()
                    }))
            }
        })
    }
}
