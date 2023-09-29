//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct AddFormulaView: View
{
    @Binding var isShowingSheet: Bool

    @State private var packageRequested: String = ""

    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState

    @State private var foundPackageSelection = Set<UUID>()

    @ObservedObject var searchResultTracker = SearchResultTracker()
    @ObservedObject var installationProgressTracker = InstallationProgressTracker()

    @State var packageInstallationProcessStep: PackageInstallationProcessSteps = .ready

    @State var packageInstallTrackingNumber: Float = 0

    @FocusState var isSearchFieldFocused: Bool

    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false
    @AppStorage("notifyAboutPackageInstallationResults") var notifyAboutPackageInstallationResults: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch packageInstallationProcessStep
            {
            case .ready:
                SheetWithTitle(title: "add-package.title")
                {
                    InstallationInitialView(
                        searchResultTracker: searchResultTracker,
                        isShowingSheet: $isShowingSheet,
                        packageRequested: $packageRequested,
                        foundPackageSelection: $foundPackageSelection,
                        installationProgressTracker: installationProgressTracker,
                        packageInstallationProcessStep: $packageInstallationProcessStep
                    )
                }

            case .searching:
                InstallationSearchingView(
                    packageRequested: $packageRequested,
                    searchResultTracker: searchResultTracker,
                    packageInstallationProcessStep: $packageInstallationProcessStep
                )

            case .presentingSearchResults:
                PresentingSearchResultsView(
                    searchResultTracker: searchResultTracker,
                    packageRequested: $packageRequested,
                    foundPackageSelection: $foundPackageSelection,
                    isShowingSheet: $isShowingSheet,
                    packageInstallationProcessStep: $packageInstallationProcessStep,
                    installationProgressTracker: installationProgressTracker
                )

            case .installing:
                InstallingPackageView(
                    installationProgressTracker: installationProgressTracker,
                    packageInstallationProcessStep: $packageInstallationProcessStep
                )

            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        HeadlineWithSubheadline(
                            headline: "add-package.finished",
                            subheadline: "add-package.finished.description",
                            alignment: .leading
                        )
                    }
                }
                .onAppear
                {
                    appState.cachedDownloadsFolderSize = directorySize(url: AppConstants.brewCachedDownloadsPath)

                    if notifyAboutPackageInstallationResults
                    {
                        sendNotification(title: String(localized: "notification.install-finished"))
                    }
                }

            case .fatalError: /// This shows up when the function for executing the install action throws an error
                    VStack(alignment: .leading)
                    {
                        ComplexWithIcon(systemName: "exclamationmark.triangle") 
                        {
                            HeadlineWithSubheadline(
                                headline: "add-package.fatal-error-\(installationProgressTracker.packagesBeingInstalled.first!.package.name)",
                                subheadline: "add-package.fatal-error.description",
                                alignment: .leading
                            )
                        }

                        HStack
                        {
                            Button
                            {
                                restartApp()
                            } label: {
                                Text("action.restart")
                            }

                            Spacer()

                            DismissSheetButton(isShowingSheet: $isShowingSheet)
                        }
                    }

            default:
                VStack(alignment: .leading)
                {
                    ComplexWithIcon(systemName: "wifi.exclamationmark")
                    {
                        HeadlineWithSubheadline(
                            headline: "add-package.network-error",
                            subheadline: "add-package.network-error.description",
                            alignment: .leading
                        )
                    }

                    HStack
                    {
                        Spacer()

                        DismissSheetButton(isShowingSheet: $isShowingSheet)
                    }
                }
            }
        }
        .padding()
    }
}
