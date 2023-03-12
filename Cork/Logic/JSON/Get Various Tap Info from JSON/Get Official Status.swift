//
//  Get Official Status.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import SwiftyJSON

func getTapOfficialStatusFromJSON(json: JSON) -> Bool
{
    return json[0, "official"].boolValue
}
