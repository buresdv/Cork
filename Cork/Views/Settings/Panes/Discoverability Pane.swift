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
                }
                .disabled(!enableDiscoverability)
            }
        }
    }
}
