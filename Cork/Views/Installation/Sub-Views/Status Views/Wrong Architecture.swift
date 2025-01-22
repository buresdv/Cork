//
//  Wrong Architecture.swift
//  Cork
//
//  Created by David Bureš on 31.03.2024.
//

import SwiftUI

struct WrongArchitectureView: View, Sendable
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    var body: some View
    {
        ComplexWithIcon(systemName: "cpu")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "add-package.install.wrong-architecture.title",
                    subheadline: "add-package.install.wrong-architecture-\(installationProgressTracker.packageBeingInstalled.package.name).user-architecture-is-\(ProcessInfo().CPUArchitecture == .arm ? "Apple Silicon" : "Intel")",
                    alignment: .leading
                )

                HStack
                {
                    Spacer()

                    Button
                    {
                        dismiss()

                        Task.detached
                        {
                            do
                            {
                                try await brewData.synchronizeInstalledPackages()
                            }
                            catch let synchronizationError
                            {
                                await appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: synchronizationError.localizedDescription))
                            }
                            
                        }
                    } label: {
                        Text("action.close")
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
        .fixedSize()
    }
}
