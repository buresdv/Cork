//
//  Add Tap Button.swift
//  Cork
//
//  Created by David Bureš - Virtual on 12.06.2025.
//

import SwiftUI

struct AddTapButton: View
{
    let appState: AppState
    
    var body: some View
    {
        Button
        {
            appState.showSheet(ofType: .tapAddition)
        } label: {
            Label("navigation.menu.packages.add-tap", image: "custom.spigot.badge.plus")
        }
    }
}
