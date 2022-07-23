//
//  Search Result.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation

struct SearchResult: Identifiable {
    let id = UUID()
    let packageName: String
    let isCask: Bool
}
