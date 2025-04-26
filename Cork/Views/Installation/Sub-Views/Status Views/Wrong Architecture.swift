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
    
    let packageThatWasGettingInstalled: BrewPackage

    var body: some View
    {
        ComplexWithIcon(systemName: "cpu")
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "add-package.install.wrong-architecture.title",
                    subheadline: "add-package.install.wrong-architecture-\(packageThatWasGettingInstalled.name).user-architecture-is-\(ProcessInfo().CPUArchitecture == .arm ? "Apple Silicon" : "Intel")",
                    alignment: .leading
                )
            }
        }
        .fixedSize()
    }
}
