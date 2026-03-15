//
//  Tag Untag Button.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import CorkShared
import SwiftUI
import CorkModels
import FactoryKit

struct TagUntagButton: View
{
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let package: BrewPackage

    var body: some View
    {
        Button
        {
            brewPackagesTracker.updatePackageInPlace(package)
            { package in
                package.changeTaggedStatus(purpose: .actuallyChangingTheTaggedState)
            }
        } label: {
            Label(package.isTagged ? "sidebar.section.all.contextmenu.untag-\(package.name(withPrecision: .precise))" : "sidebar.section.all.contextmenu.tag-\(package.name(withPrecision: .precise))", systemImage: package.isTagged ? "tag.slash" : "tag")
        }
    }
}
