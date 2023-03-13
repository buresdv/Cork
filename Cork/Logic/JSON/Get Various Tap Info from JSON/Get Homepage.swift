//
//  Get Homepage.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import SwiftyJSON

func getTapHomepageFromJSON(json: JSON) -> URL
{
    return URL(string: json[0, "remote"].stringValue)!
}
