//
//  Confirmation Dialog - Main Window.swift
//  Cork
//
//  Created by David Bureš - P on 21.04.2025.
//

import Foundation
import SwiftUI

enum ConfirmationDialog: Identifiable, Equatable
{
    case uninstallPackage(_ packageToUninstall: BrewPackage)

    case purgePackage(_ packageToPurge: BrewPackage)

    var id: UUID
    {
        return .init()
    }

    var title: LocalizedStringKey
    {
        switch self
        {
        case .uninstallPackage(let packageToUninstall):
            return "action.uninstall.confirm.title.\(packageToUninstall.name)"
        case .purgePackage(let packageToPurge):
            return "action.purge.confirm.title.\(packageToPurge.name)"
        }
    }
    
    var message: LocalizedStringKey
    {
        switch self {
        case .uninstallPackage(_), .purgePackage(_):
            return "action.warning.cannot-be-undone"
        }
    }
}
