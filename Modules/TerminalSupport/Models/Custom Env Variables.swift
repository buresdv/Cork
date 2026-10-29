//
//  Custom Env Variables.swift
//  Cork
//
//  Created by David Bureš - P on 30.04.2026.
//

import Foundation
import Defaults

public extension Defaults.Keys
{
    static let customEnvVariables: Key<[EnvironmentVariable]> = .init("customEnvVariables", default: .init())
    
    static let showInheritedEnvVariables: Key<Bool> = .init("customEnvVariables_showInheritedVariables", default: false)
    
    static let showUserEnvVariables: Key<Bool> = .init("customEnvVariables_showUserVariables", default: true)
    
    static let showMandatoryEnvVariables: Key<Bool> = .init("customMandatoryVariables_showUserVariables", default: false)
}
