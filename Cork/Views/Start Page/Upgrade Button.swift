//
//  Upgrade Button.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 14/02/2023.
//

import Foundation
import SwiftUI

struct UpgradeButton: View {
    var body: some View {
        Button
        {
            upgradeBrewPackages(updateProgressTracker)
        } label: {
            Label
            {
                Text("Upgrade Formulae")
            } icon: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .keyboardShortcut("r")
    }
}
