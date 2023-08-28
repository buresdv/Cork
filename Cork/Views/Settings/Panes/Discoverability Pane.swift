//
//  Discoverability Pane.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI

struct DiscoverabilityPane: View
{
    @AppStorage("enableDiscoverability") var enableDiscoverability: Bool = false
    @AppStorage("discoverabilityDaySpan") var discoverabilityDaySpan: DiscoverabilityDaySpans = .month
    @AppStorage("sortTopPackagesBy") var sortTopPackagesBy: TopPackageSorting = .mostDownloads
    
    @EnvironmentObject var appState: AppState

    var body: some View
    {
        SettingsPaneTemplate
        {
            VStack(alignment: .center, spacing: 10)
            {
                Toggle(isOn: $enableDiscoverability)
                {
                    Text("settings.discoverability.toggle")
                }
                .toggleStyle(.switch)
                .disabled(appState.isLoadingTopPackages)

                Divider()

                Form
                {
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
