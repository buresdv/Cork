//
//  Package Search Token.swift
//  Cork
//
//  Created by David Bureš on 14.03.2023.
//

import Foundation
import SwiftUI

enum PackageSearchToken
{
    case formula, cask, tap, tag, intentionallyInstalledPackage
}

extension PackageSearchToken: Identifiable
{
    var id: Int
    {
        hashValue
    }
}

extension PackageSearchToken
{
    var name: LocalizedStringKey {
        switch self {
        case .formula:
            return "search.token.filter-formulae"
        case .cask:
            return "search.token.filter-casks"
        case .tap:
            return "search.token.filter-taps"
        case .tag:
            return "search.token.filter-tags"
        case .intentionallyInstalledPackage:
            return "search.token.filter-manually-installed-packages"
        }
    }

    var icon: String {
        switch self {
        case .formula:
            return "terminal"
        case .cask:
            return "macwindow"
        case .tap:
            return "spigot"
        case .tag:
            return "tag"
        case .intentionallyInstalledPackage:
            return "hand.tap"
        }
    }
}
