//
//  Package Name Displayable.swift
//  CorkModels
//
//  Created by David Bureš - P on 29.04.2026.
//

import Foundation
import SwiftUI

/// Adds support for parsing, storing and displaying a Brew package name in a friendly manner
public protocol PackageNameDisplayable
{
    typealias BrewPackageName = BrewPackage.BrewPackageName
    typealias NameRetrievalPrecision = BrewPackage.NameRetrievalPrecision

    /// The internal name, consisting of the raw name being split into re-constructable sections
    var internalName: BrewPackageName { get set }

    /// Reconstruct the internal name into a Brew-compatible format
    func name(withPrecision precision: NameRetrievalPrecision) -> String

    /// SwiftUI view for displaying the package's name
    associatedtype NameView: View
    @ViewBuilder var nameView: NameView { get }
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
    var nameView: some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 5)
        {
            Text(self.internalName.packageIdentifier)

            if let boundVersion = self.internalName.boundVersion
            {
                Text("v. \(boundVersion)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
    }
}
