//
//  Get Installed Packages Intent.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation
import CorkModels

struct GetInstalledPackagesIntent: AppIntent
{
    @Parameter(title: "intent.get-installed-packages.limit-to-manually-installed-packages")
    var getOnlyManuallyInstalledPackages: Bool

    static let title: LocalizedStringResource = "intent.get-installed-packages.title"
    static let description: LocalizedStringResource = "intent.get-installed-packages.description"

    static let isDiscoverable: Bool = true
    static let openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<[MinimalHomebrewPackage]>
    {
        let installedMinimalFormulae: [MinimalHomebrewPackage] = try await GetInstalledFormulaeIntent(getOnlyManuallyInstalledPackages: $getOnlyManuallyInstalledPackages).perform().value ?? .init()

        let installedMinimalCasks: [MinimalHomebrewPackage] = try await GetInstalledCasksIntent().perform().value ?? .init()

        return .result(value: installedMinimalFormulae + installedMinimalCasks)
    }
}
