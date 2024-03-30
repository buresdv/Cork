//
//  Menu Bar Item.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBarItem: View
{
    @Environment(\.openWindow) var openWindow
    
    @ObservedObject var appState: AppState
    
    @ObservedObject var brewData: BrewDataStorage
    @ObservedObject var availableTaps: AvailableTaps
    
    @ObservedObject var outdatedPackageTracker: OutdatedPackageTracker
    
    @Binding var isUninstallingOrphanedPackages: Bool
    @Binding var isPurgingHomebrewCache: Bool
    @Binding var isDeletingCachedDownloads: Bool
    
    var body: some View
    {
        Text("menu-bar.state-overview-\(brewData.installedFormulae.count)-\(brewData.installedCasks.count)-\(availableTaps.addedTaps.count)")

        Divider()

        if outdatedPackageTracker.outdatedPackages.count > 0
        {
            Menu
            {
                ForEach(outdatedPackageTracker.outdatedPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
                { outdatedPackage in
                    SanitizedPackageName(packageName: outdatedPackage.package.name, shouldShowVersion: false)
                }
            } label: {
                Text("notification.outdated-packages-found.body-\(outdatedPackageTracker.outdatedPackages.count)")
            }

            Button("navigation.upgrade-packages")
            {
                switchCorkToForeground()
                appState.isShowingUpdateSheet = true
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
            appState.isShowingInstallationSheet.toggle()
        }

        Divider()

        if !isUninstallingOrphanedPackages
        {
            Button("maintenance.steps.packages.uninstall-orphans")
            {
                Task(priority: .userInitiated)
                {
                    AppConstants.logger.log("Will delete orphans")

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
                        AppConstants.logger.error("Failed while uninstalling orphans: \(orphanUninstallationError, privacy: .public)")

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
                    AppConstants.logger.log("Will purge cache")

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
                        AppConstants.logger.warning("There were errors while purging Homebrew cache: \(cachePurgingError.localizedDescription, privacy: .public)")

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
            Button(appState.cachedDownloadsFolderSize != 0 ? "maintenance.steps.downloads.delete-cached-downloads" : "navigation.menu.maintenance.no-cached-downloads")
            {
                AppConstants.logger.log("Will delete cached downloads")

                isDeletingCachedDownloads = true

                let reclaimedSpaceAfterCachePurge = Int(appState.cachedDownloadsFolderSize)

                deleteCachedDownloads()

                sendNotification(
                    title: String(localized: "maintenance.results.cached-downloads"),
                    body: String(localized: "maintenance.results.cached-downloads.summary-\(reclaimedSpaceAfterCachePurge.formatted(.byteCount(style: .file)))"),
                    sensitivity: .active
                )

                isDeletingCachedDownloads = false

                appState.cachedDownloadsFolderSize = directorySize(url: AppConstants.brewCachedDownloadsPath)
            }
            .disabled(appState.cachedDownloadsFolderSize == 0)
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
}
