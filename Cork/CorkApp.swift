//
//  CorkApp.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

@main
struct CorkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands(content: {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button {
                    appDelegate.showAboutPanel()
                } label: {
                    Text("About \(AppConstantsLocal.appName)")
                }
            }
        })
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
        // .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: true))
        // .windowStyle(HiddenTitleBarWindowStyle())
    }
}
