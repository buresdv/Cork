//
//  Package Caveats.swift
//  Cork
//
//  Created by David Bureš on 28.02.2023.
//

import Foundation
import Defaults

public enum PackageCaveatDisplay: String, Codable, CaseIterable, Defaults.Serializable
{
    case full, mini
}
