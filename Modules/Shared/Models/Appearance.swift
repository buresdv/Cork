//
//  Appearance.swift
//  CorkShared
//
//  Created by David Bureš - P on 11.11.2026.
//

import Foundation
import Defaults
import SwiftUI

public enum Appearance: String, Identifiable, CaseIterable, Defaults.Serializable
{
    public var id: Self
    {
        return self
    }
    
    case system
    case forcedLight
    case foredDark
    
    public var description: String
    {
        switch self
        {
        case .system:
            return String(localized: "settings.general.appearance.system")
        case .forcedLight:
            return String(localized: "settings.general.appearance.forced-light")
        case .foredDark:
            return String(localized: "settings.general.appearance.forced-dark")
        }
    }
    
    public var setting: ColorScheme?
    {
        switch self {
        case .system:
            return nil
        case .forcedLight:
            return .light
        case .foredDark:
            return .dark
        }
    }
}
