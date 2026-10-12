//
//  Custom Env Variable.swift
//  Cork
//
//  Created by David Bureš - P on 30.04.2026.
//

import Defaults
import Foundation

public final class EnvironmentVariable: Identifiable, Codable, Hashable, Defaults.Serializable, Sendable
{    
    public static func == (lhs: borrowing EnvironmentVariable, rhs: borrowing EnvironmentVariable) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
        hasher.combine(self.value)
    }
    
    public let id: UUID

    public let key: String
    public let value: String

    public init(key: String, value: String)
    {
        self.id = .init()
        self.key = key
        self.value = value
    }
}

public extension [EnvironmentVariable]
{
    /// Initialize an array of ``EnvironmentVariable`` from the raw dictionary returned by the process
    init(environment: [String: String])
    {
        self.init(environment.map
        { (key: String, value: String) in
            EnvironmentVariable(key: key, value: value)
        })
    }
}

public extension [String: String]
{
    init(environmentVariables: [EnvironmentVariable])
    {
        self.init(environmentVariables: environmentVariables.map
        { environmentVariable in
            .init(key: environmentVariable.key, value: environmentVariable.value)
        })
    }
}
