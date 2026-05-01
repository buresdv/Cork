//
//  Package Name Displayable.swift
//  CorkModels
//
//  Created by David Bureš - P on 29.04.2026.
//

import Foundation
import SwiftUI
import CorkShared

/// Adds support for parsing, storing and displaying a Brew package name in a friendly manner
public protocol PackageNameDisplayable
{
    typealias NameRetrievalPrecision = BrewPackage.NameRetrievalPrecision
    typealias NameComponents = BrewPackage.NameDisplayComponents

    /// The internal name, consisting of the raw name being split into re-constructable sections
    var internalName: BrewPackageName { get set }

    /// Reconstruct the internal name into a Brew-compatible format
    func name(withPrecision precision: NameRetrievalPrecision) -> String

    /// SwiftUI view for displaying the package's name
    associatedtype NameView: View
    @ViewBuilder
    func nameView(withComponents: NameComponents...) -> NameView
}

/// The package's name parsed into chunks
public struct BrewPackageName: Equatable, Hashable, Codable, Sendable
{
    public init(from unparsedName: String)
    {
        let packageNameWithoutTap: String =
        { /// First, remove the tap name from the package name if it has it
            /// If there are no slashes, return the package name, as we don't need to modify the slashes
            guard unparsedName.contains("/")
            else
            {
                return unparsedName
            }

            if let sanitizedName = try? unparsedName.regexMatch("[^\\/]*$")
            { /// Try to remove everything before the last slash
                return sanitizedName
            }
            else
            { /// If the removal of the slashes doesn't work, return the unmodified name
                return unparsedName
            }
        }()

        /// If there is no `@` - meaning there is no bound version - just init with the name without the tap slashes
        guard packageNameWithoutTap.contains("@")
        else
        {
            self.packageIdentifier = unparsedName
            self.boundVersion = nil

            return
        }

        let splitPackageName: [String] = packageNameWithoutTap.components(separatedBy: "@")

        /// Check if there are actually only two components to the name - if not, something went wrong, and we return the unparsed name
        guard splitPackageName.count == 2
        else
        {
            AppConstants.shared.logger.error("Failed while parsing package name \(packageNameWithoutTap, privacy: .public). Name should not contain more than two components at this stage.")

            self.packageIdentifier = packageNameWithoutTap
            self.boundVersion = nil

            return
        }

        if let packageIdentifier = splitPackageName.first, let boundVersion = splitPackageName.last
        {
            self.packageIdentifier = packageIdentifier
            self.boundVersion = boundVersion
        }
        else
        {
            AppConstants.shared.logger.error("Failed while parsing package name \(packageNameWithoutTap, privacy: .public). There should be at least two elements in the split version at this stage.")

            self.packageIdentifier = packageNameWithoutTap
            self.boundVersion = nil
        }
    }

    /// The core name of the package
    ///
    /// If the package has a bound version, this is the part before the `@`.  In the case of `cork@beta`, the Package Identifier is `cork`
    public let packageIdentifier: String

    /// The bound version of the package, designating its specific version or release
    ///
    /// If the package has a bound version, this is the part after the `@`. In the case of `cork@beta`, the Bound Version is `beta`
    public let boundVersion: String?
}

public extension PackageNameDisplayable
{
    func name(withPrecision precision: NameRetrievalPrecision) -> String
    {
        switch precision
        {
        case .general:
            return self.internalName.packageIdentifier
        case .precise:
            guard let boundVersionUnwrapped = internalName.boundVersion
            else
            {
                return self.internalName.packageIdentifier
            }

            return "\(self.internalName.packageIdentifier)@\(boundVersionUnwrapped)"
        }
    }
}

public extension PackageNameDisplayable
{
    func nameView(withComponents displayComponents: NameComponents...) -> some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 5)
        {
            Text(self.internalName.packageIdentifier)

            if let installedVersion = displayComponents.first(where: { $0.installedVersionValue != nil })?.installedVersionValue
            {
                Text("v. \(installedVersion)")
                    .foregroundColor(.green)
                    .font(.subheadline)
            }
            
            if displayComponents.contains(.boundVersion)
            {
                if let boundVersion = self.internalName.boundVersion
                {
                    Text("􀎡 \(boundVersion)")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
        }
    }
}
