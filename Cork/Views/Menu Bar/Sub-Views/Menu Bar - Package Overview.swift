//
//  Menu Bar - Package Overview.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct MenuBar_PackageOverview: View
{
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

    var body: some View
    {
        Text("menu-bar.state-overview-\(brewData.installedFormulae.count)-\(brewData.installedCasks.count)-\(availableTaps.addedTaps.count)")
    }
}
