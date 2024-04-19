//
//  Uninstallation Progress Wheel.swift
//  Cork
//
//  Created by David Bureš on 20.02.2023.
//

import SwiftUI

struct UninstallationProgressWheel: View
{
    @EnvironmentObject var appState: AppState

    var body: some View
    {
        if appState.isShowingUninstallationProgressView
        {
            // TODO: Replace the modifiers with .controlSize
            ProgressView()
                .scaleEffect(0.5, anchor: .center)
                .frame(width: 1, height: 1)
        }
    }
}
