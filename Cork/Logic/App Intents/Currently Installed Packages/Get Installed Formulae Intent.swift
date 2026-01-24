//
//  Get Installed Formulae Intent.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation
import CorkShared
import CorkModels

enum FolderAccessingError: LocalizedError
{
    case couldNotObtainPermissionToAccessFolder(formattedPath: String)

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotObtainPermissionToAccessFolder(let formattedPath):
            return String(localized: "error.permissions.could-not-obtain-folder-access-permissions.\(formattedPath)")
        }
    }
}

struct GetInstalledFormulaeIntent: AppIntent
{
    @Parameter(title: "intent.get-installed-packages.limit-to-manually-installed-packages")
    var getOnlyManuallyInstalledPackages: Bool

    static let title: LocalizedStringResource = "intent.get-installed-formulae.title"
    static let description: LocalizedStringResource = "intent.get-installed-formulae.description"

    static let isDiscoverable: Bool = true
    static let openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<[MinimalHomebrewPackage]>
    {
        let allowAccessToFile: Bool = AppConstants.shared.brewCellarPath.startAccessingSecurityScopedResource()

        if allowAccessToFile
        {
            let dummyBrewData: BrewPackagesTracker = await .init()
            
            guard let installedFormulae: BrewPackages = await dummyBrewData.loadInstalledPackages(packageTypeToLoad: .formula, appState: AppState()) else
            {
                throw IntentError.failedWhilePerformingIntent
            }

            /// Filter out all packages that gave an error
            let validInstalledFormulae: Set<BrewPackage> = Set(installedFormulae.compactMap { rawResult in
                if case let .success(success) = rawResult {
                    return success
                }
                else
                {
                    return nil
                }
            })
            
            AppConstants.shared.brewCellarPath.stopAccessingSecurityScopedResource()

            var minimalPackages: [MinimalHomebrewPackage] = validInstalledFormulae.map
            { package in
                .init(name: package.getPackageName(withPrecision: .precise), type: .formula, installedIntentionally: package.installedIntentionally)
            }

            if getOnlyManuallyInstalledPackages
            {
                minimalPackages = minimalPackages.filter({ $0.installedIntentionally })
            }

            return .result(value: minimalPackages)
        }
        else
        {
            print("Could not obtain access to folder")
            throw FolderAccessingError.couldNotObtainPermissionToAccessFolder(formattedPath: AppConstants.shared.brewCellarPath.absoluteString)
        }
    }
}
