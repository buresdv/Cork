//
//  Minimal Homebrew Package.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import AppIntents
import Foundation

public struct MinimalHomebrewPackage: Identifiable, Hashable, AppEntity, Codable
{
    public init(name: String, type: BrewPackage.PackageType, installDate: Date? = nil, installedIntentionally: Bool) {
        self.id = .init()
        self.name = name
        self.type = type
        self.installDate = installDate
        self.installedIntentionally = installedIntentionally
    }
    
    public var id: UUID

    public var name: String

    public var type: BrewPackage.PackageType

    public var installDate: Date?

    public var installedIntentionally: Bool

    public static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "intents.type.minimal-homebrew-package")

    public var displayRepresentation: DisplayRepresentation
    {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "intents.type.minimal-homebrew-package.representation.subtitle"
        )
    }

    public static let defaultQuery: MinimalHomebrewPackageIntentQuery = .init()
}

public extension MinimalHomebrewPackage
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

public struct MinimalHomebrewPackageIntentQuery: EntityQuery
{
    public func entities(for _: [UUID]) async throws -> [MinimalHomebrewPackage]
    {
        return .init()
    }
    
    public init() {}
}
