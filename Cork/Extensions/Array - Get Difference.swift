//
//  Array - Get Difference.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation

extension Array where Element: Hashable
{
    func difference(from other: [Element]) -> [Element]
    {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
