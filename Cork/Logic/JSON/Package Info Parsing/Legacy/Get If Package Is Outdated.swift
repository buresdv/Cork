//
//  Get If Package Is Outdated.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import Foundation
import SwiftyJSON

func getIfPackageIsOutdated(json: JSON, package: BrewPackage) -> Bool
{
    if package.type == .formula
    {
        return json["formulae", 0, "outdated"].boolValue
    }
    else
    {
        return json["casks", 0, "outdated"].boolValue
    }
}
