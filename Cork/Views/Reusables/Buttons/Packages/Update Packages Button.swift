//
//  Update Packages Button.swift
//  Cork
//
//  Created by David Bureš - Virtual on 12.06.2025.
//

import SwiftUI
import CorkPackagesModels

struct UpgradePackagesButton: View
{
    
    let appState: AppState
    
    var body: some View
    {
        Button
        {
            appState.showSheet(ofType: .fullUpdate)
        } label: {
            Label("navigation.menu.packages.update", systemImage: "square.and.arrow.down")
        }
    }
}
