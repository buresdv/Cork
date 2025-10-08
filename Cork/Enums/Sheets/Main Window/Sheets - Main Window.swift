//
//  Sheets - Main Window.swift
//  Cork
//
//  Created by David Bureš - P on 19.01.2025.
//

import Foundation

enum DisplayableSheet: Identifiable, Equatable
{
    
    case packageInstallation
    
    case tapAddition
    
    case fullUpdate, partialUpdate(packagesToUpdate: [OutdatedPackage])
    
    case massAppAdoption(appsToAdopt: [BrewPackagesTracker.AdoptableApp])
    
    case corruptedPackageFix(corruptedPackage: CorruptedPackage)
    
    case sudoRequiredForPackageRemoval 
    
    case maintenance(fastCacheDeletion: Bool)
    
    case brewfileExport, brewfileImport
    
    var id: UUID
    {
        return .init()
    }
}
