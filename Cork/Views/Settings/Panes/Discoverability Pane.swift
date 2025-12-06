//
//  Discoverability Pane.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI
import CorkShared
import Defaults
import CorkModels

struct DiscoverabilityPane: View
{
    @Default(.enableDiscoverability) var enableDiscoverability: Bool
    @Default(.discoverabilityDaySpan) var discoverabilityDaySpan: DiscoverabilityDaySpans
    @Default(.sortTopPackagesBy) var sortTopPackagesBy: TopPackageSorting
    @Default(.allowMassPackageAdoption) var allowMassPackageAdoption: Bool
    @Default(.hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable) var hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable: Bool

    @Environment(AppState.self) var appState: AppState

    var body: some View
    {
        SettingsPaneTemplate
        {
            VStack(alignment: .center, spacing: 10)
            {
                Defaults.Toggle(key: .enableDiscoverability)
                {
                    Text("settings.discoverability.toggle")
                }
                .onChange
                {
                    if $0 == false
                    {
                        allowMassPackageAdoption = false
                    }
                }
                .toggleStyle(.switch)
                .disabled(appState.isLoadingTopPackages)
                
                Divider()

                Form
                {
                    LabeledContent
                    {
                        VStack(alignment: .leading, spacing: 6)
                        {
                            Defaults.Toggle(key: .allowMassPackageAdoption)
                            {
                                Text("settings.discoverability.mass-adoption.toggle")
                            }
                            .disabled(!enableDiscoverability)
                            
                            Defaults.Toggle(key: .hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable)
                            {
                                Text("settings.discoverability.mass-adoption.hide-adoptable-packages-section-if-there-are-only-excluded-apps-available.label")
                            }
                        }
                    } label: {
                        Text("settings.discoverability.mass-adoption.label")
                    }
                    
                    Picker("settings.discoverability.time-span", selection: $discoverabilityDaySpan)
                    {
                        ForEach(DiscoverabilityDaySpans.allCases)
                        { discoverabilitySpan in
                            Text(discoverabilitySpan.key)
                        }
                    }

                    Picker("settings.discoverability.sorting", selection: $sortTopPackagesBy)
                    {
                        ForEach(TopPackageSorting.allCases)
                        { topPackageSortType in
                            Text(topPackageSortType.key)
                        }
                    }
                }
                .disabled(!enableDiscoverability || appState.isLoadingTopPackages)
            }
        }
    }
}
