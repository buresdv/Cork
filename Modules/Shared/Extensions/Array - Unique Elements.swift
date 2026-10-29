//
//  Array - Unique Elements.swift
//  CorkShared
//
//  Created by David Bureš - P on 13.10.2026.
//
// https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/

import Foundation

public extension Sequence
{
    func unique<T: Hashable>(by keyForValue: (Iterator.Element) throws -> T) rethrows -> [Iterator.Element]
    {
        var seen: Set<T> = []
        return try filter { try seen.insert(keyForValue($0)).inserted }
    }
}
