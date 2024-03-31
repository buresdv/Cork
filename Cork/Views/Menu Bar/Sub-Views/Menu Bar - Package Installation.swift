//
//  Menu Bar - Package Installation.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBar_PackageInstallation: View
{
    @EnvironmentObject var appState: AppState

    var body: some View
    {
        Button("navigation.install-package")
        {
            switchCorkToForeground()
            appState.isShowingInstallationSheet.toggle()
        }
    }
}
