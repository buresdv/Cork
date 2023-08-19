//
//  Top Package Sorting.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI

enum TopPackageSorting: Hashable, Identifiable, CaseIterable
{
    var id: Self { self }
    
    case byMostDownloads, byFewestDownloads, random
    
    var key: LocalizedStringKey
    {
        switch self {
            case .byMostDownloads:
                return "settings.discoverability.sorting.by-most-downloads"
            case .byFewestDownloads:
                return "settings.discoverability.sorting.by-fewest-downloads"
            case .random:
                return "settings.discoverability.sorting.random"
        }
    }
}
