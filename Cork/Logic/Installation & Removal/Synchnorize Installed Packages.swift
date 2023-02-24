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
func synchronizeInstalledPackages(brewData: BrewDataStorage) async -> Void
{
    let oldBrewData: BrewDataStorage = brewData
    
    let oldFormulaeSorted: [BrewPackage] = sortPackagesAlphabetically(oldBrewData.installedFormulae)
    let oldCasksSorted: [BrewPackage] = sortPackagesAlphabetically(oldBrewData.installedCasks)
    
    let dummyAppState: AppState = AppState()
    dummyAppState.isLoadingFormulae = false
    dummyAppState.isLoadingCasks = false
    
    /// These have to use this dummy AppState, which forces them to not activate the "loading" animation. We don't want the entire thing to re-draw
    let newFormulaeSorted: [BrewPackage] = await loadUpFormulae(appState: dummyAppState, sortBy: .byInstallDate)
    let newCasksSorted: [BrewPackage] = await loadUpCasks(appState: dummyAppState, sortBy: .byInstallDate)
    
    var formulaeDifference: [BrewPackage] = .init()
    var casksDifference: [BrewPackage] = .init()
    
    // MARK: Packages have been added
    if oldFormulaeSorted.count < newFormulaeSorted.count
    {
        print("Formulae have been added")
        formulaeDifference = Array(newFormulaeSorted.dropFirst(oldFormulaeSorted.count))
        
        withAnimation {
            brewData.installedFormulae.append(contentsOf: formulaeDifference)
        }
    }
    if oldCasksSorted.count < newCasksSorted.count
    {
        print("Casks have been added")
        casksDifference = Array(newCasksSorted.dropFirst(oldCasksSorted.count))
        
        withAnimation {
            brewData.installedCasks.append(contentsOf: casksDifference)
        }
    }
    
    // MARK: Packages have been removed
    if oldFormulaeSorted.count > newFormulaeSorted.count
    {
        print("Formulae have been removed")
        
        var oldFormulaeMutable: [BrewPackage] = oldFormulaeSorted
        
        for _ in oldFormulaeSorted
        {
            for newFormula in newFormulaeSorted
            {
                withAnimation {
                    oldFormulaeMutable.removeAll(where: { $0.name == newFormula.name })
                }
            }
        }
        
        print("Different formulae (\(oldFormulaeMutable.count)): \(oldFormulaeMutable)")
        
        for _ in brewData.installedFormulae
        {
            for differentPackage in oldFormulaeMutable
            {
                withAnimation {
                    brewData.installedFormulae.removeAll(where: { $0.name == differentPackage.name })
                }
            }
        }
    }
    if oldCasksSorted.count > newCasksSorted.count
    {
        print("Casks have been removed")
        
        var oldCasksMutable: [BrewPackage] = oldCasksSorted
        
        for _ in oldCasksSorted
        {
            for newCask in newCasksSorted
            {
                withAnimation {
                    oldCasksMutable.removeAll(where: { $0.name == newCask.name })
                }
            }
        }
        
        print("Different casks (\(oldCasksMutable.count)): \(oldCasksMutable)")
        
        for _ in brewData.installedCasks
        {
            for differentPackage in oldCasksMutable
            {
                withAnimation {
                    brewData.installedCasks.removeAll(where: { $0.name == differentPackage.name })
                }
            }
        }
    }
}
