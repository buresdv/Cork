//
//  Menu Bar - Package Installation.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI
import CorkModels
import FactoryKit

struct MenuBar_PackageInstallation: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    @InjectedObservable(\.appState) var appState: AppState

    var body: some View
    {
        Button("navigation.install-package")
        {
            openWindow(id: "main")
            switchCorkToForeground()
            appState.showSheet(ofType: .packageInstallation)
        }
    }
}
