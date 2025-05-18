//
//  Cork Shortcuts.swift
//  Cork
//
//  Created by David Bureš on 26.05.2024.
//

import AppIntents
import Foundation

struct CorkShortcuts: AppShortcutsProvider
{
    static var appShortcuts: [AppShortcut]
    {
        .init(
            intent: GetInstalledPackagesIntent(),
            phrases: [
                "Show me my installed Homebrew packages in ${applicationName}"
            ],
            shortTitle: "action.intents.get-installed-packages.short-title",
            systemImageName: "shippingbox"
        )
    }
}
