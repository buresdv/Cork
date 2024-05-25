//
//  Get Installed Formulae Intent.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import Foundation
import AppIntents

struct GetInstalledFormulaeIntent: AppIntent
{
    static var title: LocalizedStringResource = "intent.get-installed-formulae.title"
    static var description: LocalizedStringResource = "intent.get-installed-formulae.description"
    
    static var isDiscoverable: Bool = false
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some ReturnsValue<> {
        <#code#>
    }
}
