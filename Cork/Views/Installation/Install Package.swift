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
                PackageInstallationFinishedView(isShowingSheet: $isShowingSheet)

            case .fatalError: /// This shows up when the function for executing the install action throws an error
                PackageInstallationFatalErrorView(installationProgressTracker: installationProgressTracker, isShowingSheet: $isShowingSheet)

            case .requiresSudoPassword:
                VStack(alignment: .leading)
                {
                    ComplexWithIcon(systemName: "exclamationmark.triangle.fill")
                    {
                        VStack(alignment: .leading, spacing: 10)
                        {
                            Text("add-package.install.requires-sudo-password-\(installationProgressTracker.packagesBeingInstalled[0].package.name)")
                                .font(.headline)

                            ManualInstallInstructions(installationProgressTracker: installationProgressTracker)
                        }
                    }

                    Text("add.package.install.requires-sudo-password.terminal-instructions-\(installationProgressTracker.packagesBeingInstalled[0].package.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    HStack
                    {
                        Button
                        {
                            isShowingSheet = false

                            Task.detached
                            {
                                await synchronizeInstalledPackages(brewData: brewData)
                            }
                        } label: {
                            Text("action.close")
                        }
                        .keyboardShortcut(.cancelAction)

                        Spacer()

                        Button
                        {
                            openTerminal()
                        } label: {
                            Text("action.open-terminal")
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .fixedSize()

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

private struct ManualInstallInstructions: View
{
    let installationProgressTracker: InstallationProgressTracker

    var manualInstallCommand: String
    {
        return "brew install \(installationProgressTracker.packagesBeingInstalled[0].package.isCask ? "--cask" : "") \(installationProgressTracker.packagesBeingInstalled[0].package.name)"
    }

    var body: some View
    {
        VStack
        {
            Text("add-package.install.requires-sudo-password.description")

            GroupBox
            {
                HStack(alignment: .center, spacing: 5)
                {
                    Text(manualInstallCommand)

                    Divider()

                    Button
                    {
                        copyToClipboard(whatToCopy: manualInstallCommand)
                    } label: {
                        Label
                        {
                            Text("action.copy")
                        } icon: {
                            Image(systemName: "doc.on.doc")
                        }
                        .help("action.copy-manual-install-command-to-clipboard")
                    }
                }
                .padding(3)
            }
        }
    }
}

private func openTerminal()
{
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") else { return }

    let path = "/bin"
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.arguments = [path]
    NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
}
