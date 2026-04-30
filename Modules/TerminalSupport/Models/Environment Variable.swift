//
//  Custom Env Variable.swift
//  Cork
//
//  Created by David Bureš - P on 30.04.2026.
//

import Defaults
import Foundation

public class EnvironmentVariable: Identifiable, Codable, Defaults.Serializable
{
    public var id: UUID

    public var key: String
    public var value: String

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
