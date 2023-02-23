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
}
