//
//  String - Contains Element of Array.swift
//  CorkShared
//
//  Created by David Bureš - P on 14.04.2026.
//

import Foundation

public extension String
{
    func containsAny(of substrings: [String]) -> Bool
    {
        substrings.contains(where: { self.contains($0) })
    }

    func containsElementFromArray(_ arrayOfComponents: [any RegexComponent]) -> Bool
    {
        arrayOfComponents.contains { contains($0) }
    }
}
