//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

#warning("TODO: Implement these different alerts")
private enum AlertType
{
    case uninstallationNotPossibleDueToDependency, couldNotApplyTaggedStateToPackages, couldNotClearMetadata, metadataFolderDoesNotExist, couldNotCreateCorkMetadataDirectory, couldNotCreateCorkMetadataFile
}

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

    @State private var alertType: AlertType = .uninstallationNotPossibleDueToDependency

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
                    }
                }
                catch let uuidLoadingError as NSError
                {
                    print("Failed while loading UUIDs from file: \(uuidLoadingError)")
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
        .alert(isPresented: $appState.isShowingUninstallationNotPossibleDueToDependencyAlert, content: {
            switch alertType
            {
            case .uninstallationNotPossibleDueToDependency:
                return Alert(
                    title: Text("alert.unable-to-uninstall-dependency.title"),
                    message: Text("alert.unable-to-uninstall-dependency.message-\(appState.offendingDependencyProhibitingUninstallation)"),
                    dismissButton: .default(Text("action.close"), action: {
                        appState.isShowingUninstallationNotPossibleDueToDependencyAlert = false
                    })
                )

            case .couldNotApplyTaggedStateToPackages:
                return Alert(
                    title: Text("Could not apply tagged state to packages"),
                    message: Text("Try restarting Cork. If the problem persists, clear Cork metadata."),
                    primaryButton: .cancel(Text("action.close"), action: {
                        appState.isShowingUninstallationNotPossibleDueToDependencyAlert = false
                    }),
                    secondaryButton: .destructive(Text("Clear Metadata"), action: {
                        if FileManager.default.fileExists(atPath: AppConstants.documentsDirectoryPath.path)
                        {
                            do
                            {
                                try FileManager.default.removeItem(atPath: AppConstants.documentsDirectoryPath.path)
                                restartApp()
                            }
                            catch
                            {
                                alertType = .couldNotClearMetadata
                            }
                        }
                        else
                        {
                            alertType = .metadataFolderDoesNotExist
                        }
                    })
                )

            case .couldNotClearMetadata:
                return Alert(
                    title: Text("Could not clear metadata"),
                    message: Text("Delete the metadata folder manually, or try restarting Cork."),
                    primaryButton: .cancel(Text("action.close"), action: {}),
                    secondaryButton: .default(Text("Reveal Metadata in Finder"), action: {
                        if FileManager.default.fileExists(atPath: AppConstants.documentsDirectoryPath.path)
                        {
                            NSWorkspace.shared.open(AppConstants.documentsDirectoryPath)
                        }
                        else
                        {
                            alertType = .metadataFolderDoesNotExist
                        }
                    })
                )

            case .metadataFolderDoesNotExist:
                return Alert(
                    title: Text("Could not find metadata folder"),
                    message: Text("Reinstall Cork and try again"),
                    dismissButton: .default(Text("action.close"), action: {})
                )

            case .couldNotCreateCorkMetadataDirectory:
                    return Alert(
                        title: Text("Could not create Metadata folder"),
                        message: Text("Make sure you've given Cork permission to access your Documents folder"),
                        dismissButton: .default(Text("Restart Cork"), action: {
                        restartApp()
                    }))
            case .couldNotCreateCorkMetadataFile:
                    return Alert(
                        title: Text("Could not create Metadata file"),
                        message: Text("Make sure you've given Cork permission to access your Documents folder"),
                        dismissButton: .default(Text("Restart Cork"), action: {
                        restartApp()
                    }))
            }
        })
    }
}
