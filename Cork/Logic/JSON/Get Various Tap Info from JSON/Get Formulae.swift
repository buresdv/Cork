//
//  Get Formulae.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import SwiftyJSON

func getFormulaeAvailableFromTap(json: JSON, tap: BrewTap) -> [String]?
{
    var availableFormulae: [String]? = nil
    let numberOfCharactersInTapName: Int = tap.name.count + 1
    
    let availableFormulaeFromTap = json[0, "formula_names"].arrayValue
    
    for availableFormula in availableFormulaeFromTap {
        if availableFormulae == nil
        {
            availableFormulae = [availableFormula.stringValue]
        }
        else
        {
            availableFormulae?.append(availableFormula.stringValue)
        }
    }
    
    print(availableFormulae)
    
    return availableFormulae
}
