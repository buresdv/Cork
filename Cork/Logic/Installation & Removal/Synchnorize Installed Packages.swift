//
//  Synchnorize Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 23.02.2023.
//

import Foundation
import SwiftUI

/// What this function does:
/// **Background**
/// When a package is installed or uninstalled, its dependencies don't show up in the package list, because there's no system for getting them. I needed a way for all new packages to show up/disappear even when they were not installed manually
/// **Motivation**
/// Because I can't fucking figure out why I can't subtract one array from another, I had to come up with this contrived mess
/// **Process**
/// The function works like this
/// 1. Load up installed *formulae* and *casks* after an install/uninstall process has finished
/// 2. Sort the array of both the old and new packages by install date
/// 3. Compare them to see which one is newer:
///  - If the new array is **BIGGER**, it means that packages have been *uninstalled* and we have to be **REMOVING** packages from the old array
///  - If the new array is **SMALLER**, it means that packages have been *installed* and we have to be **ADDING** packages to the old array
/// 4. Depending on what turns out to be the case:
///  - In case we need to be adding packages:
///         1. Take the length of the old array. This is where all the old packages are. Save this length into a variable *x*
///         2. From the new array, remove the first *x* elements, so we are only left with the new packages.
///  - In case we need to be removing packages:
///         1. Copy the old array into another array, called *mutable*, where we will do all the operations
///         2. In the first for loop, check each package in the old array against each package in the new array. If their names match, it means that this package was not removed, so remove it from the *mutable* array
///         3. When this process finished, we are left with only packages that are in the old array, but not in the new array: In other words, all the packages that have been removed
///         4. In the second for loop, check each package in the old array against each package in the final *mutable* array. If the names of packages match, remove them; if they match, it means that this package has been removed

@MainActor
func synchronizeInstalledPackages(brewData: BrewDataStorage) async
{
    let dummyAppState: AppState = .init()
    dummyAppState.isLoadingFormulae = false
    dummyAppState.isLoadingCasks = false

    /// These have to use this dummy AppState, which forces them to not activate the "loading" animation. We don't want the entire thing to re-draw
    let newFormulae: Set<BrewPackage> = await loadUpPackages(whatToLoad: .formula, appState: dummyAppState)
    let newCasks: Set<BrewPackage> = await loadUpPackages(whatToLoad: .cask, appState: dummyAppState)

    if newFormulae.count != brewData.installedFormulae.count
    {
        withAnimation
        {
            brewData.installedFormulae = newFormulae
        }
    }

    if newCasks.count != brewData.installedCasks.count
    {
        withAnimation
        {
            brewData.installedCasks = newCasks
        }
    }
}
