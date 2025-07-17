//
//  Minimal Homebrew Package.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation

struct MinimalHomebrewPackage: Identifiable, Hashable, AppEntity, Codable
{
    var id: UUID = .init()

    var name: String

    var type: PackageType

    var installDate: Date?

    var installedIntentionally: Bool

    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "intents.type.minimal-homebrew-package")

    var displayRepresentation: DisplayRepresentation
    {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "intents.type.minimal-homebrew-package.representation.subtitle"
        )
    }

    static let defaultQuery: MinimalHomebrewPackageIntentQuery = .init()
}

extension MinimalHomebrewPackage
{
    init?(from homebrewPackage: BrewPackage?)
    {
        guard let homebrewPackage = homebrewPackage
        else
        {
            return nil
        }

        self.init(
            name: homebrewPackage.name,
            type: homebrewPackage.type,
            installedIntentionally: homebrewPackage.installedIntentionally
        )
    }
}

struct MinimalHomebrewPackageIntentQuery: EntityQuery
{
    func entities(for _: [UUID]) async throws -> [MinimalHomebrewPackage]
    {
        return .init()
    }
}
