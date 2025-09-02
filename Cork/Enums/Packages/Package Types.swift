//
//  Package Types.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import AppIntents
import Charts
import CorkShared
import Foundation
import SwiftUI

enum PackageType: String, CustomStringConvertible, Plottable, AppEntity, Codable
{
    case formula
    case cask

    /// User-readable description of the package type
    var description: String
    {
        switch self
        {
        case .formula:
            return String(localized: "package-details.type.formula")
        case .cask:
            return String(localized: "package-details.type.cask")
        }
    }

    /// Localization keys for description of the package type
    var localizableDescription: LocalizedStringKey
    {
        switch self
        {
        case .formula:
            return "package-details.type.formula"
        case .cask:
            return "package-details.type.cask"
        }
    }

    /// Parent folder for this package type
    var parentFolder: URL
    {
        switch self
        {
        case .formula:
            return AppConstants.shared.brewCellarPath
        case .cask:
            return AppConstants.shared.brewCaskPath
        }
    }

    /// Accessibility representation
    var accessibilityLabel: LocalizedStringKey
    {
        switch self
        {
        case .formula:
            return "accessibility.label.package-type.formula"
        case .cask:
            return "accessibility.label.package-type.cask"
        }
    }

    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "package-details.type")

    var displayRepresentation: DisplayRepresentation
    {
        switch self
        {
        case .formula:
            DisplayRepresentation(title: "package-details.type.formula")
        case .cask:
            DisplayRepresentation(title: "package-details.type.cask")
        }
    }
}
