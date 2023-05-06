//
//  Package And Tap Status Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct PackageAndTapOverviewBox: View
{
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

    var body: some View
    {
        GroupBox
        {
            VStack(alignment: .leading)
            {
                GroupBoxHeadlineGroup(
                    image: "terminal",
                    title: LocalizedStringKey(String.localizedPluralString("start-page.installed-formulae.count", brewData.installedFormulae.count)),
                    mainText: "start-page.installed-formulae.description"
                )
                .animation(.none, value: brewData.installedFormulae.count)

                Divider()

                GroupBoxHeadlineGroup(
                    image: "macwindow",
                    title: LocalizedStringKey(String.localizedPluralString("start-page.installed-casks.count", brewData.installedCasks.count)),
                    mainText: "start-page.installed-casks.description"
                )
                .animation(.none, value: brewData.installedCasks.count)

                Divider()

                GroupBoxHeadlineGroup(
                    image: "spigot",
                    title: LocalizedStringKey(String.localizedPluralString("start-page.added-taps.count", availableTaps.addedTaps.count)),
                    mainText: "start-page.added-taps.description"
                )
                .animation(.none, value: availableTaps.addedTaps.count)
            }
        }
    }
}
