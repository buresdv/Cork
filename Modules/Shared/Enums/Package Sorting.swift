//
//  Package Sorting.swift
//  CorkShared
//
//  Created by David Bureš - P on 10.03.2025.
//

import Foundation
import Defaults

public enum PackageSortingOptions: String, Codable, CaseIterable, Defaults.Serializable
{
    case alphabetically, byInstallDate, bySize
}
