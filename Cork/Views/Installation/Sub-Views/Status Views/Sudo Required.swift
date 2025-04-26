//
//  Sudo Required.swift
//  Cork
//
//  Created by David Bureš on 19.11.2023.
//

import SwiftUI

struct SudoRequiredView: View, Sendable
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    let packageThatWasGettingInstalled: BrewPackage

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ComplexWithImage(image: Image(localURL: URL(filePath: "/System/Library/CoreServices/KeyboardSetupAssistant.app/Contents/Resources/AppIcon.icns"))!)
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("add-package.install.requires-sudo-password-\(packageThatWasGettingInstalled.name)")
                        .font(.headline)

                    manualInstallInstructions
                }
            }

            Text("add.package.install.requires-sudo-password.terminal-instructions-\(packageThatWasGettingInstalled.name)")
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
    
    @ViewBuilder
    var manualInstallInstructions: some View
    {
        var manualInstallCommand: String
        {
            return "brew install \(packageThatWasGettingInstalled.type == .cask ? "--cask" : "") \(packageThatWasGettingInstalled.name)"
        }
        
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
