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
    @Parameter(title: "intent.get-installed-packages.limit-to-manually-installed-packages")
    var getOnlyManuallyInstalledPackages: Bool

    static var title: LocalizedStringResource = "intent.get-installed-packages.title"
    static var description: LocalizedStringResource = "intent.get-installed-packages.description"

    static var isDiscoverable: Bool = true
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<[MinimalHomebrewPackage]>
    {
        let installedMinimalFormulae: [MinimalHomebrewPackage] = try await GetInstalledFormulaeIntent(getOnlyManuallyInstalledPackages: $getOnlyManuallyInstalledPackages).perform().value ?? .init()

        let installedMinimalCasks: [MinimalHomebrewPackage] = try await GetInstalledCasksIntent().perform().value ?? .init()

        return .result(value: installedMinimalFormulae + installedMinimalCasks)
    }
}
