//
//  Get Package Homepage.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import Foundation
import SwiftyJSON

func getPackageHomepageFromJSON(json: JSON, package: BrewPackage) -> URL
{
    if package.type == .formula
    {
        return URL(string: json["formulae", 0, "homepage"].stringValue)!
    }
    else
    {
        return URL(string: json["casks", 0, "homepage"].stringValue)!
    }
}
