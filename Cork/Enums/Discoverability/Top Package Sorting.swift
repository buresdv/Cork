//
//  Top Package Sorting.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI

enum TopPackageSorting: Int, Hashable, Identifiable, CaseIterable
{
    var id: Self
    {
        self
    }

    case mostDownloads, fewestDownloads, random

    var key: LocalizedStringKey
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
