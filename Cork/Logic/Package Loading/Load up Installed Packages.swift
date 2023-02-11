//
//  Load up Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 09.07.2022.
//

import Foundation

@MainActor
func loadUpInstalledPackages(into brewData: BrewDataStorage, appState: AppState) async
{
    brewData.installedFormulae = await loadUpFormulae(appState: appState)
    brewData.installedCasks = await loadUpCasks(appState: appState)
}

