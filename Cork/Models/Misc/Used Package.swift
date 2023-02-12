//
//  Used Package.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation

struct UsedPackage: Identifiable
{
    var id: UUID = .init()

    let name: String
    let whyIsItUsed: String
    let packageURL: URL
}

