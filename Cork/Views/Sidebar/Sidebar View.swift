//
//  Sidebar View.swift
//  Cork
//
//  Created by David Bureš on 14.02.2023.
//

import SwiftUI

struct SidebarView: View
{
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var selectedPackageInfo: SelectedPackageInfo
    
    @ObservedObject var availableTaps: AvailableTaps

    var body: some View
    {
        List
        {
            Section("Installed Formulae")
            {
                if !appState.isLoadingFormulae
                {
                    InstalledFormulaeListSection(
                        brewData: brewData,
                        selectedPackageInfo: selectedPackageInfo,
                        appState: appState
                    )
                }
                else
                {
                    ProgressView()
                }
            }
            
            Section("Installed Casks")
            {
                if !appState.isLoadingCasks
                {
                    InstalledCasksListSection(
                        brewData: brewData,
                        selectedPackageInfo: selectedPackageInfo,
                        appState: appState
                    )
                }
                else
                {
                    ProgressView()
                }
            }
            
            Section("Tapped Taps")
            {
                if availableTaps.tappedTaps.count != 0
                {
                    ForEach(availableTaps.tappedTaps)
                    { tap in
                        Text(tap.name)
                    }
                }
                else
                {
                    ProgressView()
                }
            }
        }
        .listStyle(.sidebar)
    }
}
