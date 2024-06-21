//
//  Get Pin Status.swift
//  Cork
//
//  Created by David Bureš on 07.03.2023.
//

import Foundation
import SwiftyJSON

func getPinStatusFromJSON(json: JSON, package: BrewPackage) -> Bool
{
    if !package.isCask
    {
        return json["formulae", 0, "pinned"].boolValue
    }
    else
    {
        return json["casks", 0, "pinned"].boolValue
    }
}
