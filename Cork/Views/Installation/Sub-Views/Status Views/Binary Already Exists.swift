//
//  Binary Already Exists.swift
//  Cork
//
//  Created by David Bureš on 28.05.2024.
//

import Foundation
import SwiftUI

struct BinaryAlreadyExistsView: View, Sendable
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    @ObservedObject var installationProgressTracker: InstallationProgressTracker

    var body: some View
    {
        ComplexWithImage(image: Image(localURL: URL(filePath: "/System/Library/CoreServices/KeyboardSetupAssistant.app/Contents/Resources/AppIcon.icns"))!)
        {
            VStack(alignment: .leading, spacing: 10)
            {
                HeadlineWithSubheadline(
                    headline: "add-package.install.binary-already-exists-\(installationProgressTracker.packageBeingInstalled.package.name)",
                    subheadline: "add-package.install.binary-already-exists.subheadline",
                    alignment: .leading
                )
            }
            .toolbar
            {
                ToolbarItem(placement: .primaryAction)
                {
                    Button
                    {
                        URL.applicationDirectory.revealInFinder(.openTargetItself)
                    } label: {
                        Text("action.reveal-applications-folder-in-finder")
                    }
                }
            }
        }
        .fixedSize()
    }
}
