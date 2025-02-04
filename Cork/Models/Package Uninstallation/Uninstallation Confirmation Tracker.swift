//
//  Uninstallation Confirmation Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.04.2024.
//

import Foundation
import SwiftUI

@MainActor
class UninstallationConfirmationTracker: ObservableObject
{
    @Published var isShowingUninstallOrPurgeConfirmation: Bool = false

    @Published private(set) var packageThatNeedsConfirmation: BrewPackage = .init(name: "", type: .formula, installedOn: Date(), versions: [], url: nil)
    @Published private(set) var shouldPurge: Bool = false
    @Published private(set) var isCalledFromSidebar: Bool = false

    func showConfirmationDialog(packageThatNeedsConfirmation: BrewPackage, shouldPurge: Bool, isCalledFromSidebar: Bool)
    {
        self.packageThatNeedsConfirmation = packageThatNeedsConfirmation
        self.shouldPurge = shouldPurge
        self.isCalledFromSidebar = isCalledFromSidebar

        isShowingUninstallOrPurgeConfirmation = true
    }

    func dismissConfirmationDialog()
    {
        if isShowingUninstallOrPurgeConfirmation
        {
            isShowingUninstallOrPurgeConfirmation = false
        }

        packageThatNeedsConfirmation = .init(name: "", type: .formula, installedOn: Date(), versions: [], url: nil)
    }
}
