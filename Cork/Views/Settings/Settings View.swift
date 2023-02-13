//
//  Settings View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            InstallationPane()
                .tabItem {
                    Label("Package Installation", systemImage: "plus")
                }
        }
    }
}
