//
//  Top Package Sorting.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI
import Defaults

public enum TopPackageSorting: Int, Hashable, Identifiable, CaseIterable, Defaults.Serializable
{
    public var id: Self
    {
        self
    }

    case mostDownloads, fewestDownloads, random

    public var key: LocalizedStringKey
    {
        switch self
        {
        case .mostDownloads:
            return "settings.discoverability.sorting.by-most-downloads"
        case .fewestDownloads:
            return "settings.discoverability.sorting.by-fewest-downloads"
        case .random:
            return "settings.discoverability.sorting.random"
        }
    }
}
