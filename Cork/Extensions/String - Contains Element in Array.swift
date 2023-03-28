//
//  String - Contains Element in Array.swift
//  Cork
//
//  Created by David Bureš on 23.02.2023.
//

import Foundation

extension String {
    func containsElementFromArray(_ strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }
    
    static func localizedPluralString(_ key: String, _ number: Int) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String.localizedStringWithFormat(format, NSNumber(value: number), number.formatted())
    }
}
