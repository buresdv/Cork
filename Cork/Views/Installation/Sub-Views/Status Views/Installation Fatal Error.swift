//
//  Installation Fatal Error.swift
//  Cork
//
//  Created by David Bureš - P on 24.01.2025.
//

import SwiftUI

struct InstallationFatalErrorView: View
{
    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    var body: some View
    {
        ComplexWithIcon(systemName: "exclamationmark.triangle")
        {
            HeadlineWithSubheadline(
                headline: "add-package.fatal-error-\(installationProgressTracker.packageBeingInstalled.package.name)",
                subheadline: "add-package.fatal-error.description",
                alignment: .leading
            )
        }
        .toolbar
        {
            ToolbarItem(placement: .destructiveAction)
            {
                Button
                {
                    restartApp()
                } label: {
                    Text("action.restart")
                }
            }
        }
    }
}
