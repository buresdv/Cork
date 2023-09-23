//
//  Return Formatted Versions.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func returnFormattedVersions(_ array: [String]) -> String
{
    return array.formatted(.list(type: .and, width: .narrow))
}
