//
//  CorkApp.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

@main
struct CorkApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
        //.windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: true))
        //.windowStyle(HiddenTitleBarWindowStyle())
    }
}
