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
    
    @Published private(set) var packageThatNeedsConfirmation: BrewPackage = .init(name: "", isCask: false, installedOn: Date(), versions: [], sizeInBytes: 0)
    @Published private(set) var shouldPurge: Bool = false
    @Published private(set) var isCalledFromSidebar: Bool = false

    func showConfirmationDialog(packageThatNeedsConfirmation: BrewPackage, shouldPurge: Bool, isCalledFromSidebar: Bool)
    {
        self.packageThatNeedsConfirmation = packageThatNeedsConfirmation
        self.shouldPurge = shouldPurge
        self.isCalledFromSidebar = isCalledFromSidebar
        
        self.isShowingUninstallOrPurgeConfirmation = true
    }
    
    func dismissConfirmationDialog()
    {
        if self.isShowingUninstallOrPurgeConfirmation
        {
            self.isShowingUninstallOrPurgeConfirmation = false
        }
        
        self.packageThatNeedsConfirmation = .init(name: "", isCask: false, installedOn: Date(), versions: [], sizeInBytes: 0)
    }
}
