//
//  Get Installed Packages Intent.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation

struct GetInstalledPackagesIntent: AppIntent
{
    static var title: LocalizedStringResource = "intent.get-installed-packages.title"
    static var description: LocalizedStringResource = "intent.get-installed-packages.description"
    
    static var isDiscoverable: Bool = false
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some ReturnsValue<[MinimalHomebrewPackage]>
    {
        let installedMinimalFormulae: [MinimalHomebrewPackage] = try await GetInstalledFormulaeIntent().perform().value!
        
        let installedMinimalCasks: [MinimalHomebrewPackage] = try await GetInstalledCasksIntent().perform().value!
        
        return .result(value: installedMinimalFormulae + installedMinimalCasks)
    }
}

