//
//  Get Installed Casks Intent.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation

struct GetInstalledCasksIntent: AppIntent
{
    static var title: LocalizedStringResource = "intent.get-installed-casks.title"
    static var description: LocalizedStringResource = "intent.get-installed-casks.description"
    
    static var isDiscoverable: Bool = false
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some ReturnsValue<[MinimalHomebrewPackage]>
    {
        let installedFormulae = await loadUpPackages(whatToLoad: .cask, appState: AppState())
        
        let minimalPackages: [MinimalHomebrewPackage] = installedFormulae.map { package in
            return .init(name: package.name, type: .cask)
        }
        
        return .result(value: minimalPackages)
    }
}
