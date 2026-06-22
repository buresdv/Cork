//
//  Minimal Homebrew Package.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import AppIntents
import Foundation
import SwiftUI

public struct MinimalHomebrewPackage: Identifiable, Hashable, AppEntity, Codable, Package, DescriptionLoadable
{
    /// Initialize from an unparsed name
    public init(name: String, type: BrewPackage.PackageType, installDate: Date? = nil, installedIntentionally: Bool) {
        self.id = .init()
        self.internalName = .init(from: name)
        self.type = type
        self.installedOn = installDate
        self.installedIntentionally = installedIntentionally
    }
    
    /// Initialize from a full package
    public init(fromFullPackage fullPackage: BrewPackage)
    {
        self.id = .init()
        self.internalName = fullPackage.internalName
        self.type = fullPackage.type
        self.installedOn = fullPackage.installedOn
        self.installedIntentionally = fullPackage.installedIntentionally
    }
    
    public var id: UUID

    public var internalName: BrewPackageName

    public var type: BrewPackage.PackageType

    public var installedOn: Date?

    public var installedIntentionally: Bool?

    @ViewBuilder
    public var previewSelfButton: some View
    {
        if let installedOn
        {
            EmptyView()
        }
        else
        {
            PreviewPackageButton(packageToPreview: self)
        }
    }
    
    @ViewBuilder
    public var openDetailForSelfButton: some View
    {
        #if DEBUG
        Text(String("DEBUG: Detail for self button not available for minimal packages"))
        #endif
    }
    
    public static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "intents.type.minimal-homebrew-package")

    public var displayRepresentation: DisplayRepresentation
    {
        DisplayRepresentation(
            title: "\(name(withPrecision: .precise))",
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
            name: homebrewPackage.name(withPrecision: .precise),
            type: homebrewPackage.type,
            installedIntentionally: homebrewPackage.installedIntentionally
        )
    }
}

public extension MinimalHomebrewPackage
{
    /// Initialize an empty minimal package, for when we don't care what it is
    init(createEmpty: Bool)
    {
        self.init(name: "", type: .formula, installedIntentionally: false)
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
