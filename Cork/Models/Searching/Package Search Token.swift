//
//  Package Search Token.swift
//  Cork
//
//  Created by David Bureš on 14.03.2023.
//

import Foundation
import SwiftUI

enum TokenSearchType
{
    case formula, cask, tap, tag, intentionallyInstalledPackage
}

struct PackageSearchToken: Identifiable
{
    var id = UUID()
    var name: LocalizedStringKey
    var tokenSearchResultType: TokenSearchType
}
