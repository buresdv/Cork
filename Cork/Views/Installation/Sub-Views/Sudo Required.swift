//
//  Sudo Required.swift
//  Cork
//
//  Created by David Bureš on 19.11.2023.
//

import SwiftUI

struct SudoRequiredView: View, Sendable
{
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var brewData: BrewDataStorage
    
    @ObservedObject var installationProgressTracker: InstallationProgressTracker
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            ComplexWithImage(image: Image(localURL: URL(filePath: "/System/Library/CoreServices/KeyboardSetupAssistant.app/Contents/Resources/AppIcon.icns"))!)
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("add-package.install.requires-sudo-password-\(installationProgressTracker.packageBeingInstalled.package.name)")
                        .font(.headline)

                    ManualInstallInstructions(installationProgressTracker: installationProgressTracker)
                }
            }

            Text("add.package.install.requires-sudo-password.terminal-instructions-\(installationProgressTracker.packageBeingInstalled.package.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack
            {
                Button
                {
                    dismiss()

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
    }
}

private struct ManualInstallInstructions: View
{
    let installationProgressTracker: InstallationProgressTracker
    
    var manualInstallCommand: String
    {
        return "brew install \(installationProgressTracker.packageBeingInstalled.package.isCask ? "--cask" : "") \(installationProgressTracker.packageBeingInstalled.package.name)"
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
