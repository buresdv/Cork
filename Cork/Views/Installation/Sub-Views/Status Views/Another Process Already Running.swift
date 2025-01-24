//
//  Another Process Already Running.swift
//  Cork
//
//  Created by David Bureš - P on 24.01.2025.
//

import SwiftUI

struct AnotherProcessAlreadyRunningView: View
{
    @EnvironmentObject var appState: AppState

    var body: some View
    {
        ComplexWithImage(image: Image(localURL: URL(string: "/System/Library/CoreServices/KeyboardSetupAssistant.app/Contents/Resources/AppIcon.icns")!)!)
        {
            VStack(alignment: .leading, spacing: 10)
            {
                Text("add-package.install.another-homebrew-process-blocking-install.title")
                    .font(.headline)

                Text("add-package.install.another-homebrew-process-blocking-install.description")
            }
            .toolbar
            {
                ToolbarItem(placement: .destructiveAction)
                {
                    Button("add-package.clear-brew-locks", role: .destructive)
                    {
                        if let contentsOfLockFolder = try? FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/usr/local/var/homebrew/locks"), includingPropertiesForKeys: [.isRegularFileKey])
                        {
                            for lockURL in contentsOfLockFolder
                            {
                                try? FileManager.default.removeItem(at: lockURL)
                            }
                        }

                        appState.dismissSheet()
                    }
                }
            }
        }
    }
}
