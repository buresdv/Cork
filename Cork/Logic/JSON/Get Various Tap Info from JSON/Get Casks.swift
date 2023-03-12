//
//  Get Casks.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import SwiftyJSON

func getCasksAvailableFromTap(json: JSON, tap: BrewTap) -> [String]?
{
    var availableCasks: [String]? = nil
    
    let availableCasksFromTap = json[0, "cask_tokens"].arrayValue
    
    for availableCask in availableCasksFromTap
    {
        let availableCaskFinal = availableCask.stringValue.replacingOccurrences(of: "\(tap.name)/", with: "")
        
        if availableCasks == nil
        {
            availableCasks = [availableCaskFinal]
        }
        else
        {
            availableCasks?.append(availableCaskFinal)
        }
    }
    
    print(availableCasks)
    
    return availableCasks
}
