//
//  Package Sorting.swift
//  CorkShared
//
//  Created by David Bureš - P on 10.03.2025.
//

import Foundation
import Defaults

public enum PackageSortingOptions: Codable, CaseIterable, Identifiable, Defaults.Serializable
{
    case alphabetically, byInstallDate, bySize
    
    public var id: Self { self }

    public var description: LocalizedStringResource
    {
        switch self
        {
        case .alphabetically:
            return "settings.general.sort-packages.alphabetically"
        case .byInstallDate:
            return "settings.general.sort-packages.install-date"
        case .bySize:
            return "settings.general.sort-packages.size"
        }
    }
}
