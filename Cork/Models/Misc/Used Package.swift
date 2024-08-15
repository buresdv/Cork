//
//  Used Package.swift
//  Cork
//
//  Created by David Bureš on 11.02.2023.
//

import Foundation
import SwiftUI

struct UsedPackage: Identifiable
{
    var id: UUID = .init()

    let name: LocalizedStringKey
    let whyIsItUsed: LocalizedStringKey
    let packageURL: URL
}
