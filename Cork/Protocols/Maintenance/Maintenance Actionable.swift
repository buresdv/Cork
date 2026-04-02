//
//  Maintenance Actionable.swift
//  Cork
//
//  Created by David Bureš - P on 27.03.2026.
//

import Foundation
import SwiftUI

/// Defines requirements for a maintenance step
protocol MaintenanceActionable
{
    /// Name for the action that will show up in the UI
    ///
    /// `Purge cache`, `Uninstall Orphans`
    var actionName: LocalizedStringKey { get }
    
    /// Name for what the action does
    ///
    /// `Purging cache...`, `Uninstalling orphans...`
    var actionInProgressName: LocalizedStringKey { get }
    
    /// Whether the action is selected to be performed
    //var isSelected: Bool { get set }
}
