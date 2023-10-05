//
//  Fatal Error.swift
//  Cork
//
//  Created by David Bureš on 05.10.2023.
//

import SwiftUI

struct PackageInstallationFatalErrorView: View
{

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    @Binding var isShowingSheet: Bool

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ComplexWithIcon(systemName: "exclamationmark.triangle")
            {
                if let packageBeingInstalled = installationProgressTracker.packagesBeingInstalled.first
                { /// Show this when we can pull out which package was being installed
                    HeadlineWithSubheadline(
                        headline: "add-package.fatal-error-\(packageBeingInstalled.package.name)",
                        subheadline: "add-package.fatal-error.description",
                        alignment: .leading
                    )
                }
                else
                { /// Otherwise, show a generic error
                    HeadlineWithSubheadline(
                        headline: "add-package.fatal-error.generic",
                        subheadline: "add-package.fatal-error.description",
                        alignment: .leading
                    )
                }
            }

            HStack
            {
                Button
                {
                    restartApp()
                } label: {
                    Text("action.restart")
                }

                Spacer()

                DismissSheetButton(isShowingSheet: $isShowingSheet)
            }
        }
    }
}
