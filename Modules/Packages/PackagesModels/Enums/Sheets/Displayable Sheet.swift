//
//  Displayable Sheet.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public enum DisplayableSheet: Identifiable, Equatable
{
    
    case packageInstallation
    
    case tapAddition
    
    case fullUpdate, partialUpdate(packagesToUpdate: [OutdatedPackage])
    
    case massAppAdoption(appsToAdopt: [BrewPackagesTracker.AdoptableApp])
    
    case corruptedPackageFix(corruptedPackage: CorruptedPackage)
    
    case sudoRequiredForPackageRemoval
    
    case maintenance(fastCacheDeletion: Bool)
    
    case brewfileExport, brewfileImport
    
    public var id: UUID
    {
        return .init()
    }
}
