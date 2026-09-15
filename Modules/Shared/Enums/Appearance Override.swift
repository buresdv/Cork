//
//  Appearance Override.swift
//  CorkShared
//
//  Created by Ameer Hamza on 09.08.2026.
//

import Foundation
import SwiftUI
import Defaults

public enum AppearanceOverride: String, Codable, CaseIterable, Identifiable, Defaults.Serializable
{
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var id: Self { self }

    public var description: LocalizedStringResource
    {
        switch self
        {
        case .system:
            return LocalizedStringResource("settings.general.appearance.system", defaultValue: "System")
        case .light:
            return LocalizedStringResource("settings.general.appearance.light", defaultValue: "Light")
        case .dark:
            return LocalizedStringResource("settings.general.appearance.dark", defaultValue: "Dark")
        }
    }

    public var colorScheme: ColorScheme?
    {
        switch self
        {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
