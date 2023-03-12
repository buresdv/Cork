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
    let numberOfCharactersInTapName: Int = tap.name.count + 1
    
    let availableCasksFromTap = json[0, "cask_tokens"].arrayValue
    
    for availableCask in availableCasksFromTap
    {
        if availableCasks == nil
        {
            availableCasks = [availableCask.stringValue]
        }
        else
        {
            availableCasks?.append(availableCask.stringValue)
        }
    }
    
    print(availableCasks)
    
    return availableCasks
}
