//
//  Install Package Button.swift
//  Cork
//
//  Created by David Bureš - Virtual on 12.06.2025.
//

import SwiftUI
import CorkModels

struct InstallPackageButton: View
{
    let appState: AppState
    
    var body: some View
    {
        Button
        {
            appState.showSheet(ofType: .packageInstallation)
        } label: {
            Label("navigation.menu.packages.install", image: "custom.shippingbox.badge.plus")
        }
        .help("navigation.install-package.help")
    }
}
