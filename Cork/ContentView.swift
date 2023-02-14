//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View
{
    @StateObject var brewData = BrewDataStorage()

    @StateObject var availableTaps = AvailableTaps()

    @StateObject var selectedPackageInfo = SelectedPackageInfo()
    @StateObject var updateProgressTracker = UpdateProgressTracker()

    @State private var multiSelection = Set<UUID>()

    @State private var isShowingInstallSheet: Bool = false
    @State private var isShowingTapSheet: Bool = false
    @State private var isShowingAlert: Bool = false

    var body: some View
    {
        VStack
        {
            NavigationView
            {
                List(selection: $multiSelection)
                {
                    InstalledFormulaeListSection(brewData, selectedPackageInfo)
                    
                    InstalledCaskListSection(brewData, selectedPackageInfo)

                    TappedTapsListSection(tappedTaps: $availableTaps.tappedTaps)
                }
                .listStyle(SidebarListStyle())
                
                StartPage(brewData: brewData, updateProgressTracker: updateProgressTracker)
            }
            .navigationTitle("Cork")
            .navigationSubtitle("\(brewData.installedFormulae.count + brewData.installedCasks.count) packages installed")
            .toolbar
            {
                ToolbarItemGroup(placement: .primaryAction)
                {
                    UpgradeButton()
                    
                    Spacer()

                    AddTapButton()

                    AddFormulaeButton()
                }
            }
        }
        .environmentObject(brewData)
        .onAppear
        {
            Task
            {
                await loadUpTappedTaps(into: availableTaps)
                await loadUpInstalledPackages(into: brewData)
            }
        }
        .sheet(isPresented: $isShowingInstallSheet)
        {
            AddFormulaView(isShowingSheet: $isShowingInstallSheet, brewData: brewData)
        }
        .sheet(isPresented: $isShowingTapSheet)
        {
            AddTapView(isShowingSheet: $isShowingTapSheet, availableTaps: availableTaps)
        }
        .sheet(isPresented: $updateProgressTracker.showUpdateSheet)
        {
            VStack
            {
                ProgressView(value: updateProgressTracker.updateProgress)
                    .frame(width: 200)
                Text(updateProgressTracker.updateStage.rawValue)
            }
            .padding()
        }
    }
}
