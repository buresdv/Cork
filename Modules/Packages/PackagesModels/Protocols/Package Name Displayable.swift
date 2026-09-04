//
//  Package Name Displayable.swift
//  CorkModels
//
//  Created by David Bureš - P on 29.04.2026.
//

import CorkShared
import Defaults
import Foundation
import SwiftUI

/// Adds support for parsing, storing and displaying a Brew package name in a friendly manner
public protocol PackageNameDisplayable
{
    typealias NameRetrievalPrecision = BrewPackage.NameRetrievalPrecision
    typealias NameComponents = BrewPackage.NameDisplayComponents

    /// The internal name, consisting of the raw name being split into re-constructable sections
    var internalName: BrewPackageName { get }

    /// Type of the package
    var displayableType: BrewPackage.PackageType? { get }

    /// Reconstruct the internal name into a Brew-compatible format
    func name(withPrecision precision: NameRetrievalPrecision) -> String

    associatedtype PreviewSelfButton: View
    /// Button for previewing packages that are not installed
    var previewSelfButton: PreviewSelfButton { get }

    associatedtype OpenDetailForSelfButton: View
    /// Button for opening a package's detail
    var openDetailForSelfButton: OpenDetailForSelfButton { get }

    associatedtype RevealSelfInFinderButton: View
    /// Button for revealing the package in Finder
    var revealSelfInFinderButton: RevealSelfInFinderButton { get }
    
    /// What happens on double click
    @MainActor
    func doubleClickAction() async
}

/// The package's name parsed into chunks
public struct BrewPackageName: Equatable, Hashable, Codable, Comparable, Sendable
{
    public static func < (lhs: BrewPackageName, rhs: BrewPackageName) -> Bool
    {
        // First, compare by packageIdentifier alphabetically
        if lhs.packageIdentifier != rhs.packageIdentifier
        {
            return lhs.packageIdentifier < rhs.packageIdentifier
        }

        // If identifiers are equal, handle boundVersion comparison
        switch (lhs.boundVersion, rhs.boundVersion)
        {
        case (nil, nil): // Both have no bound version — equal
            return false

        case (nil, _): // lhs has no version, rhs does — lhs comes first
            return true

        case (_, nil): // rhs has no version, lhs does — rhs comes first
            return false

        case (let lhsVersion?, let rhsVersion?): // Both have versions
            // Check if both are purely numeric
            let lhsIsNumeric = Double(lhsVersion) != nil
            let rhsIsNumeric = Double(rhsVersion) != nil

            switch (lhsIsNumeric, rhsIsNumeric)
            {
            case (false, false): // Both alphanumeric — sort alphabetically
                return lhsVersion < rhsVersion

            case (false, true): // lhs alphanumeric, rhs numeric — lhs comes first
                return true

            case (true, false): // lhs numeric, rhs alphanumeric — rhs comes first
                return false

            case (true, true): // idk what's even happening here, I'm tired
                if let lhsNum = Double(lhsVersion), let rhsNum = Double(rhsVersion)
                {
                    return lhsNum < rhsNum
                }
                return lhsVersion < rhsVersion // Fallback to string comparison
            }
        }
    }

    public init(from unparsedName: String)
    {
        AppConstants.shared.logger.debug("Will try to parse package name \(unparsedName)")

        /// This monstrosity splits any name into two components:
        ///
        /// `marsanne/cask/cork`:
        /// `tapIdentifier` as `marsanne/cask`
        /// `packageIdentifier` as `cork`
        let packageNameAndTapExtractionRegex: Regex = #/^(?:(?<tapIdentifier>.+)/)?(?<packageIdentifierWithUnparsedBoundVersion>[^/]+)$/#

        /// Try to split the whole unparsed name according to ``packageNameAndTapExtractionRegex``
        if let packageNameMatch = unparsedName.wholeMatch(of: packageNameAndTapExtractionRegex)
        {
            // MARK: - Tap parsing (optional)

            /// Try to figure out if there is a tap name, assign that first because having like three branches made this impossible to maintain
            if let tapIdentifier = packageNameMatch.output.tapIdentifier
            {
                AppConstants.shared.logger.debug("Explicit tap identifier exists in package \(unparsedName), and it is \(String(tapIdentifier))")
                do
                {
                    self.packageTap = try .init(tapNameString: String(tapIdentifier))
                }
                catch let tapNameParsingError
                {
                    AppConstants.shared.logger.error("Failed while parsing tap name \(String(tapIdentifier), privacy: .public): \(tapNameParsingError.localizedDescription, privacy: .public)")

                    self.packageTap = nil
                }
            }
            else
            {
                self.packageTap = nil
            }

            // MARK: - Package name parsing

            let packageIdentifierWithUnparsedBoundVersion: Substring = packageNameMatch.output.packageIdentifierWithUnparsedBoundVersion

            /// If there is no `@` - meaning there is no bound version - just init with the name without the tap slashes
            guard packageIdentifierWithUnparsedBoundVersion.contains("@")
            else
            {
                self.packageIdentifier = String(packageIdentifierWithUnparsedBoundVersion)
                self.boundVersion = nil

                return
            }

            let splitPackageName: [String] = packageIdentifierWithUnparsedBoundVersion.components(separatedBy: "@")

            /// Check if there are actually only two components to the name - if not, something went wrong, and we return the unparsed name
            guard splitPackageName.count == 2
            else
            {
                AppConstants.shared.logger.error("Failed while parsing package name \(packageIdentifierWithUnparsedBoundVersion, privacy: .public). Name should not contain more than two components at this stage.")

                self.packageIdentifier = String(packageIdentifierWithUnparsedBoundVersion)
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
                AppConstants.shared.logger.error("Failed while parsing package name \(packageIdentifierWithUnparsedBoundVersion, privacy: .public). There should be at least two elements in the split version at this stage.")

                self.packageIdentifier = String(packageIdentifierWithUnparsedBoundVersion)
                self.boundVersion = nil
            }
        }
        else
        {
            AppConstants.shared.logger.info("Couldn't parse the required components of a package name")

            self.packageIdentifier = unparsedName
            self.boundVersion = nil
            self.packageTap = nil
        }
    }

    /// The tap the package is included in
    ///
    /// Usually `nil`, but can be set if there are conflicting packages from different taps
    public let packageTap: BrewTap.BrewTapName?

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
    private var tapComponentForNameReconstruction: String
    {
        if let packageTap = self.internalName.packageTap
        {
            return "\(packageTap.repo.name)/\(packageTap.tapName)/"
        }
        else
        {
            return ""
        }
    }

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
                return "\(self.tapComponentForNameReconstruction)\(self.internalName.packageIdentifier)"
            }

            return "\(self.tapComponentForNameReconstruction)\(self.internalName.packageIdentifier)@\(boundVersionUnwrapped)"
        case .inlineFormatted:
            guard let boundVersionUnwrapped = internalName.boundVersion
            else
            {
                return self.internalName.packageIdentifier
            }

            return "\(self.internalName.packageIdentifier) 􀎡 \(boundVersionUnwrapped)"
        }
    }
}

public enum BuiltInContextMenuItems
{
    case previewSelfButton
    case openPackageDetailButton
}

public extension PackageNameDisplayable
{
    /// SwiftUI view for displaying the package's name
    ///
    /// Excludes additional context menu actions
    @MainActor @ViewBuilder
    func nameView(
        withComponents components: NameComponents...,
        isExemptFromHighlighting: Bool
    ) -> some View
    {
        NameView(
            package: self,
            nameComponents: components,
            isExemptFromHighlighting: isExemptFromHighlighting
        )
        {
            EmptyView()
        }
    }

    /// SwiftUI view for displaying the package's name
    ///
    /// Includes additional context menu actions
    @MainActor @ViewBuilder
    func nameView(
        withComponents components: NameComponents...,
        isExemptFromHighlighting: Bool,
        @ViewBuilder contextMenuExtras: () -> some View
    ) -> some View
    {
        NameView(
            package: self,
            nameComponents: components,
            isExemptFromHighlighting: isExemptFromHighlighting
        )
        {
            contextMenuExtras()
        }
    }
}

/// The actual name view
private struct NameView<Package: PackageNameDisplayable, ContextMenuExtras: View>: View
{
    @Default(.showInteractiveCapsule) var showinteractiveCapsule: Bool

    let package: Package
    let nameComponents: [PackageNameDisplayable.NameComponents]

    let isExemptFromHighlighting: Bool

    @ViewBuilder var contextMenuExtras: ContextMenuExtras

    init(
        package: Package,
        nameComponents: [PackageNameDisplayable.NameComponents],
        isExemptFromHighlighting: Bool,
        @ViewBuilder contextMenuExtras: () -> ContextMenuExtras
    )
    {
        self.package = package
        self.nameComponents = nameComponents
        self.isExemptFromHighlighting = isExemptFromHighlighting
        self.contextMenuExtras = contextMenuExtras()
    }

    var body: some View
    {
        Label {
            nameView
        } icon: {
            EmptyView()
        }
        .contextMenu
        {
            package.previewSelfButton

            package.openDetailForSelfButton

            Divider()

            contextMenuExtras

            Divider()

            package.revealSelfInFinderButton
        }
    }

    /// Decides which name view to use
    @ViewBuilder
    private var nameView: some View
    {
        if isExemptFromHighlighting
        {
            NameView_NoCapsule(
                package: package,
                nameComponents: nameComponents
            )
        }
        else
        {
            switch showinteractiveCapsule
            {
            case true:
                NameView_Capsule(
                    package: package,
                    nameComponents: nameComponents
                )
            case false:
                NameView_NoCapsule(
                    package: package,
                    nameComponents: nameComponents
                )
            }
        }
    }
}

private struct NameView_Capsule<Package: PackageNameDisplayable>: View
{
    @Default(.showPackageTypeNextToInteractiveCapsule) private var showPackageTypeNextToInteractiveCapsule: Bool

    let package: Package
    let nameComponents: [PackageNameDisplayable.NameComponents]

    var body: some View
    {
        GroupBox
        {
            HStack(alignment: .center, spacing: 4)
            {
                if showPackageTypeNextToInteractiveCapsule
                {
                    packageTypeIcon
                        .foregroundStyle(.tertiary)
                }

                NameView_NoCapsule(package: package, nameComponents: nameComponents)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
        }

        var packageTypeIcon: Image
        {
            if let packageTypeIcon = package.displayableType?.icon
            {
                packageTypeIcon
            }
            else
            {
                Image(systemName: "shippingbox")
            }
        }
    }
}

private struct NameView_NoCapsule<Package: PackageNameDisplayable>: View
{
    let package: Package
    let nameComponents: [PackageNameDisplayable.NameComponents]

    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            explicitTapComponent
                .font(.footnote)

            HStack(alignment: .firstTextBaseline, spacing: 5)
            {
                Text(package.internalName.packageIdentifier)

                if nameComponents.contains(.boundVersion)
                {
                    boundVersionComponent
                }

                if let installedVersions = nameComponents.first(where: { $0.installedVersionValue != nil })?.installedVersionValue
                {
                    Text("v. \(installedVersions.formatted(.list(type: .and)))")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .layoutPriority(-Double(3))
                }
            }
        }
    }

    @ViewBuilder
    private var explicitTapComponent: some View
    {
        if let explicitlySpecifiedTap = package.internalName.packageTap
        {
            Text("\(explicitlySpecifiedTap.repo.name)/\(explicitlySpecifiedTap.tapName)")
                .foregroundStyle(.secondary)
        }
        else
        {
            #if DEBUG
                // Text("DEBUG: No explicit tap component")
            #endif
        }
    }

    @ViewBuilder
    private var boundVersionComponent: some View
    {
        if let boundVersion = package.internalName.boundVersion
        {
            HStack(alignment: .lastTextBaseline, spacing: 3)
            {
                Image(systemName: "lock.fill")
                Text(boundVersion)
            }
            .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            .font(.subheadline)
            .layoutPriority(-Double(2))
        }
    }
}
