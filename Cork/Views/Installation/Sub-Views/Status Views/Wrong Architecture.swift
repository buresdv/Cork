//
//  Wrong Architecture.swift
//  Cork
//
//  Created by David Bureš on 31.03.2024.
//

import SwiftUI
import CorkModels
import FactoryKit

struct WrongArchitectureView: View, Sendable
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @Bindable var installationProgressTracker: InstallationProgressTracker

    var body: some View
    {
        ComplexWithIcon(systemName: "cpu")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "add-package.install.wrong-architecture.title",
                    subheadline: "add-package.install.wrong-architecture-\(installationProgressTracker.packageBeingInstalled.package.name(withPrecision: .precise)).user-architecture-is-\(ProcessInfo().CPUArchitecture == .arm ? "Apple Silicon" : "Intel")",
                    alignment: .leading
                )
            }
        }
        .fixedSize()
    }
}
