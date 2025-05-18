//
//  Tagged Packages Storage.swift
//  Cork
//
//  Created by David Bureš - P on 18.05.2025.
//

import Foundation
import SwiftData

@Model
public final class SavedTaggedPackage
{
    /// Full names of packages, which includes the Homebrew version
    @Attribute(.unique) @Attribute(.spotlight)
    public var fullName: String

    public init(fullName: String) {
        self.fullName = fullName
    }
}
