//
//  Package Sorting.swift
//  Cork
//
//  Created by David Bureš on 15.02.2023.
//

import Foundation

enum PackageSortingOptions: String, Codable, CaseIterable
{
    case none, alphabetically, byInstallDate, bySize
}
