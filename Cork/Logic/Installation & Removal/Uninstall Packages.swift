//
//  Uninstall Packages.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import SwiftUI

@MainActor
func uninstallSelectedPackages(packages: [String], isCask: Bool, brewData: BrewDataStorage) async {
    for package in packages {
        if isCask {
            withAnimation {
                brewData.installedCasks.removeAll(where: { $0.name == package })
            }
        } else {
            withAnimation {
                brewData.installedFormulae.removeAll(where: { $0.name == package })
            }
        }

        print("Will try to remove package \(package)")
        let uninstallCommandOutput = await shell("/opt/homebrew/bin/brew", ["uninstall", package])

        print(uninstallCommandOutput ?? "")
    }
}
