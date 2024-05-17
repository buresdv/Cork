//
//  String - Remove Numbers.swift
//  Cork
//
//  Created by David Bureš on 17.05.2024.
//

import Foundation

extension String
{
    func numbersRemoved() -> String
    {
        return self.components(separatedBy: CharacterSet.decimalDigits).joined()
    }
}
