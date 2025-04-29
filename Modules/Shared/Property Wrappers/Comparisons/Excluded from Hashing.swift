//
//  Excluded from Hashing.swift
//  Cork
//
//  Created by David Bureš - P on 29.04.2025.
//

import Foundation

@propertyWrapper
public struct ExcludedFromHashing<Value: Equatable>: Hashable
{
    public var wrappedValue: Value

    public init(wrappedValue value: Value)
    {
        self.wrappedValue = value
    }

    public func hash(into _: inout Hasher) {}
}
