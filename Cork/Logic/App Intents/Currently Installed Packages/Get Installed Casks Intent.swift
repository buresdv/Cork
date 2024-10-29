//
//  Get Installed Casks Intent.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation
import CorkShared

struct GetInstalledCasksIntent: AppIntent
{
    static let title: LocalizedStringResource = "intent.get-installed-casks.title"
    static let description: LocalizedStringResource = "intent.get-installed-casks.description"

    static let isDiscoverable: Bool = true
    static let openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<[MinimalHomebrewPackage]>
    {
        let allowAccessToFile: Bool = AppConstants.shared.brewCaskPath.startAccessingSecurityScopedResource()

        if allowAccessToFile
        {
            let installedFormulae: Set<BrewPackage> = await loadUpPackages(whatToLoad: .cask, appState: AppState())

            AppConstants.shared.brewCaskPath.stopAccessingSecurityScopedResource()

            let minimalPackages: [MinimalHomebrewPackage] = installedFormulae.map
            { package in
                .init(name: package.name, type: .cask, installDate: package.installedOn, installedIntentionally: true)
            }

            return .result(value: minimalPackages)
        }
        else
        {
            print("Could not obtain access to folder")

            throw FolderAccessingError.couldNotObtainPermissionToAccessFolder(formattedPath: AppConstants.shared.brewCaskPath.absoluteString)
        }
    }
}
