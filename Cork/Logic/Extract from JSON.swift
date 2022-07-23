//
//  Extract from JSON.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

enum WhatToExtract: String {
    case description = "desc"
    case homepage = "homepage"
    case version = "version"
}

func extractPackageInfo(rawJSON: String, whatToExtract: WhatToExtract) -> String {
    let regex = "(?<=\(whatToExtract.rawValue)\": \").*?(?=\")"
    guard let matchedRange = rawJSON.range(of: regex, options: .regularExpression) else { return "ERROR" }
    let matchedString: String = String(rawJSON[matchedRange])
    
    return matchedString
}
