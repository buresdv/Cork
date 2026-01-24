//
//  Sudo Required.swift
//  Cork
//
//  Created by David Bureš on 19.11.2023.
//

import SwiftUI
import CorkModels

struct SudoRequiredView: View, Sendable
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Bindable var installationProgressTracker: InstallationProgressTracker

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ComplexWithImage(image: Image(localURL: URL(filePath: "/System/Library/CoreServices/KeyboardSetupAssistant.app/Contents/Resources/AppIcon.icns"))!)
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("add-package.install.requires-sudo-password-\(installationProgressTracker.packageBeingInstalled.package.getPackageName(withPrecision: .precise))")
                        .font(.headline)

                    ManualInstallInstructions(installationProgressTracker: installationProgressTracker)
                }
            }

            Text("add.package.install.requires-sudo-password.terminal-instructions-\(installationProgressTracker.packageBeingInstalled.package.getPackageName(withPrecision: .precise))")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .toolbar
        {
            ToolbarItem(placement: .primaryAction)
            {
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
    }
}

private struct ManualInstallInstructions: View
{
    let installationProgressTracker: InstallationProgressTracker

    var manualInstallCommand: String
    {
        return "brew install \(installationProgressTracker.packageBeingInstalled.package.type == .cask ? "--cask" : "") \(installationProgressTracker.packageBeingInstalled.package.getPackageName(withPrecision: .precise))"
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
                        manualInstallCommand.copyToClipboard()
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
