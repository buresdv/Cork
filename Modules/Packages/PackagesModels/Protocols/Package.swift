//
//  Package.swift
//  CorkModels
//
//  Created by David Bureš - P on 19.05.2026.
//

import FactoryKit
import Foundation
import SwiftUI

public protocol Package: Identifiable, PackageNameDisplayable
{

    var internalName: BrewPackageName { get set }

    var installedOn: Date? { get set }

    var isInstalled: Bool { get }

    var type: BrewPackage.PackageType { get set }
}

public extension Package
{
    var isInstalled: Bool
    {
        // If the package has an installed on date, it's installed. If not, it's not installed
        if self.installedOn != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
}
