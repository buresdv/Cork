//
//  Sudo Required.swift
//  Cork
//
//  Created by David Bureš on 19.11.2023.
//

import SwiftUI
import CorkModels
import FactoryKit

struct SudoRequiredView: View, Sendable
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let packageToInstall: MinimalHomebrewPackage

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ComplexWithImage(image: Image(localURL: URL(filePath: "/System/Library/CoreServices/KeyboardSetupAssistant.app/Contents/Resources/AppIcon.icns"))!)
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("add-package.install.requires-sudo-password-\(packageToInstall.name)")
                        .font(.headline)

                    ManualInstallInstructions(packageToInstall: packageToInstall)
                }
            }

            Text("add.package.install.requires-sudo-password.terminal-instructions-\(packageToInstall.name)")
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
    let packageToInstall: MinimalHomebrewPackage

    var manualInstallCommand: String
    {
        return "brew install \(packageToInstall.type == .cask ? "--cask" : "") \(packageToInstall.name)"
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
