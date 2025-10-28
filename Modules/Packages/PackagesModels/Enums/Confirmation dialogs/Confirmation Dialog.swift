//
//  Confirmation Dialog.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import SwiftUI

public enum ConfirmationDialog: Identifiable, Equatable
{
    case uninstallPackage(_ packageToUninstall: BrewPackage)

    case purgePackage(_ packageToPurge: BrewPackage)

    public var id: UUID
    {
        return .init()
    }

    public var title: LocalizedStringKey
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
        switch self
        {
        case .uninstallPackage, .purgePackage:
            return "action.warning.cannot-be-undone"
        }
    }
}
