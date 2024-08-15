//
//  Minimal Homebrew Package.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation

struct MinimalHomebrewPackage: Identifiable, Hashable, AppEntity
{
    var id: UUID = .init()

    var name: String

    var type: PackageType

    var installDate: Date?

    var installedIntentionally: Bool

    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "intents.type.minimal-homebrew-package")

    var displayRepresentation: DisplayRepresentation
    {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "intents.type.minimal-homebrew-package.representation.subtitle"
        )
    }

    static var defaultQuery = MinimalHomebrewPackageIntentQuery()
}

struct MinimalHomebrewPackageIntentQuery: EntityQuery
{
    func entities(for _: [UUID]) async throws -> [MinimalHomebrewPackage]
    {
        return .init()
    }
}
