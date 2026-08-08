//
//  Package And Tap Status Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI
import CorkShared
import Defaults
import CorkModels
import FactoryKit

struct PackageAndTapOverviewBox: View
{
    @Default(.displayOnlyIntentionallyInstalledPackagesByDefault) var displayOnlyIntentionallyInstalledPackagesByDefault: Bool

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker

    var body: some View
    {
        VStack(alignment: .leading)
        {
            GroupBoxHeadlineGroupWithArbitraryImage(
                image: BrewPackage.PackageType.formula.icon,
                title: LocalizedStringKey("start-page.installed-formulae.count-\(brewPackagesTracker.numberOfInstalledFormulae)"),
                mainText: "start-page.installed-formulae.description",
                animateNumberChanges: true
            )
            .contextMenu
            {
                RevealInFinderButtonWithArbitraryAction
                {
                    AppConstants.shared.brewCellarPath.revealInFinder(.openTargetItself)
                }
            }

            Divider()

            GroupBoxHeadlineGroupWithArbitraryImage(
                image: BrewPackage.PackageType.cask.icon,
                title: LocalizedStringKey("start-page.installed-casks.count-\(brewPackagesTracker.numberOfInstalledCasks)"),
                mainText: "start-page.installed-casks.description",
                animateNumberChanges: true
            )
            .contextMenu
            {
                RevealInFinderButtonWithArbitraryAction
                {
                    AppConstants.shared.brewCaskPath.revealInFinder(.openTargetItself)
                }
            }

            Divider()

            GroupBoxHeadlineGroup(
                image: "spigot",
                title: LocalizedStringKey("start-page.added-taps.count-\(tapTracker.addedTaps.count)"),
                mainText: "start-page.added-taps.description",
                animateNumberChanges: true
            )
            .contextMenu
            {
                RevealInFinderButtonWithArbitraryAction
                {
                    AppConstants.shared.tapPath.revealInFinder(.openTargetItself)
                }
            }
        }
    }
}
