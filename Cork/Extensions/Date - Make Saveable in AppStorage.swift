//
//  Date - Make Saveable in AppStorage.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import Foundation

extension Date: RawRepresentable
{
    public var rawValue: String
    {
        timeIntervalSinceReferenceDate.description
    }

    public init?(rawValue: String)
    {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
