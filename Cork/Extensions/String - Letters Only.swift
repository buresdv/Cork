//
//  String - Letters Only.swift
//  Cork
//
//  Created by David Bureš on 17.05.2024.
//

import Foundation

extension String 
{
    var onlyLetters: String 
    {
        return String(unicodeScalars.filter(CharacterSet.letters.contains))
    }
}
