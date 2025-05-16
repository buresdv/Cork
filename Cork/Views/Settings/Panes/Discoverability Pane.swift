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

struct DiscoverabilityPane: View
{
    @Default(.enableDiscoverability) var enableDiscoverability
    @Default(.discoverabilityDaySpan) var discoverabilityDaySpan: DiscoverabilityDaySpans
    @Default(.sortTopPackagesBy) var sortTopPackagesBy

    @Environment(AppState.self) var appState: AppState

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
