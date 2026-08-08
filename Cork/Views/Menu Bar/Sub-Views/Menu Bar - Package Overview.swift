//
//  Menu Bar - Package Overview.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI
import CorkModels
import FactoryKit

struct MenuBar_PackageOverview: View
{
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker

    var body: some View
    {
        Text("menu-bar.state-overview-\(brewPackagesTracker.numberOfInstalledFormulae)-\(brewPackagesTracker.numberOfInstalledCasks)-\(tapTracker.numberOfAddedTaps)")
    }
}
