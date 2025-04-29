//
//  Excluded From Comparing.swift
//  Cork
//
//  Created by David Bureš - P on 29.04.2025.
//

import Foundation

@propertyWrapper
public struct ExcludedFromComparing<Value>: Equatable
{
    public var wrappedValue: Value

    public init(wrappedValue: Value)
    {
        self.wrappedValue = wrappedValue
    }

    public static func == (_: ExcludedFromComparing<Value>, _: ExcludedFromComparing<Value>) -> Bool
    {
        return true
    }
}
