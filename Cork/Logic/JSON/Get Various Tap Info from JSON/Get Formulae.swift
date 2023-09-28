//
//  Get Formulae.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import SwiftyJSON

func getFormulaeAvailableFromTap(json: JSON, tap: BrewTap) -> Set<String>?
{
    var availableFormulae: Set<String>? = nil

    let availableFormulaeFromTap = json[0, "formula_names"].arrayValue
    
    for availableFormula in availableFormulaeFromTap {
        let availableFormulaFinal = availableFormula.stringValue.replacingOccurrences(of: "\(tap.name)/", with: "")
        
        if availableFormulae == nil
        {
            availableFormulae = [availableFormulaFinal]
        }
        else
        {
            availableFormulae?.insert(availableFormulaFinal)
        }
    }
    
    print(availableFormulae as Any)
    
    return availableFormulae
}
