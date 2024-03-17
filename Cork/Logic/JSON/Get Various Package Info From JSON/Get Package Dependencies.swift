//
//  Get Package Dependencies from JSON.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import Foundation
import SwiftyJSON

func getPackageDependenciesFromJSON(json: JSON, package: BrewPackage) -> [BrewPackageDependency]?
{
    var packageDependencies: [BrewPackageDependency]? = nil
    
    if !package.isCask
    {
        let installationInfos = json["formulae", 0, "installed"].arrayValue
        for installInfo in installationInfos
        {
            for dependency in installInfo["runtime_dependencies"].arrayValue
            {                
                AppConstants.logger.debug("""
Dependency:
  Name: \(dependency["full_name"].stringValue)
  Version: \(dependency["version"].stringValue)
  Directly declared: \(dependency["declared_directly"].boolValue == true ? "Yes" : "No")
""")
                
                /// This has to be here because you can't append to nil array
                /// **How It Works**
                /// If the array is nil, create it with the first element
                /// If the array is not nil (e.g. already created and available), append to it
                if packageDependencies == nil
                {
                    packageDependencies = [BrewPackageDependency(name: dependency["full_name"].stringValue, version: dependency["version"].stringValue, directlyDeclared: dependency["declared_directly"].boolValue)]
                }
                else
                {
                    packageDependencies?.append(BrewPackageDependency(name: dependency["full_name"].stringValue, version: dependency["version"].stringValue, directlyDeclared: dependency["declared_directly"].boolValue))
                }
                
            }
        }
    }
    else
    {
        return nil
    }
    
    return packageDependencies
}
