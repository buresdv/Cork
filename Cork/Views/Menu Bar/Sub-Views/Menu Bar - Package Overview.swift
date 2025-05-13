//
//  Menu Bar - Package Overview.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBar_PackageOverview: View
{
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(TapTracker.self) var tapTracker: TapTracker

    var body: some View
    {
        Text("menu-bar.state-overview-\(brewPackagesTracker.numberOfInstalledFormulae)-\(brewPackagesTracker.numberOfInstalledCasks)-\(tapTracker.numberOfAddedTaps)")
    }
}
