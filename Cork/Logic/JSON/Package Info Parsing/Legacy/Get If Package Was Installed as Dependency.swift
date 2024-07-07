//
//  Get If Package Was Installed as Dependency.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import Foundation
import SwiftyJSON

func getIfPackageWasInstalledAsDependencyFromJSON(json: JSON, package: BrewPackage) -> Bool?
{
    if package.type == .formula
    {
        var wasInstalledAsDependency: Bool?
        
        let installationInfos = json["formulae", 0, "installed"].arrayValue
        for installInfo in installationInfos
        {
            wasInstalledAsDependency = installInfo["installed_as_dependency"].boolValue
        }
        return wasInstalledAsDependency
    }
    else
    {
        return nil
    }
}
