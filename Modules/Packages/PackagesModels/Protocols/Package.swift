//
//  Package.swift
//  CorkModels
//
//  Created by David Bureš - P on 19.05.2026.
//

import Foundation

public protocol Package: Identifiable, PackageNameDisplayable
{
    var internalName: BrewPackageName { get set }

    var type: BrewPackage.PackageType { get set }
}
