//
//  Brew Pane.swift
//  Cork
//
//  Created by David Bureš on 06.03.2023.
//

import Foundation
import SwiftUI

struct BrewPane: View
{
    @AppStorage("allowBrewAnalytics") var allowBrewAnalytics: Bool = true
    @AppStorage("customHomebrewPath") var customHomebrewPath: String = ""
    @AppStorage("allowAdvancedHomebrewSettings") var allowAdvancedHomebrewSettings: Bool = false

    @State private var isPerformingBrewAnalyticsChangeCommand: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            VStack(spacing: 10)
            {
                Form
                {
                    LabeledContent
                    {
                        Toggle(isOn: $allowBrewAnalytics)
                        {
                            Text("settings.brew.collect-analytics")
                        }
                        .disabled(isPerformingBrewAnalyticsChangeCommand)
                    } label: {
                        Text("settings.brew.analytics")
                    }
                }
                .onChange(of: allowBrewAnalytics)
                { newValue in
                    if newValue == true
                    {
                        Task
                        {
                            isPerformingBrewAnalyticsChangeCommand = true

                            print("Will ENABLE analytics")
                            await shell(AppConstants.brewExecutablePath, ["analytics", "on"])

                            isPerformingBrewAnalyticsChangeCommand = false
                        }
                    }
                    else if newValue == false
                    {
                        Task
                        {
                            isPerformingBrewAnalyticsChangeCommand = true

                            print("Will DISABLE analytics")
                            await shell(AppConstants.brewExecutablePath, ["analytics", "off"])

                            isPerformingBrewAnalyticsChangeCommand = false
                        }
                    }
                }

                Divider()

                Toggle(isOn: $allowAdvancedHomebrewSettings, label: {
                    Text("settings.brew.enable-advanced-settings")
                })
                .toggleStyle(.switch)
                
                Form
                {
                    LabeledContent {
                        VStack(alignment: .leading)
                        {
                            Text(customHomebrewPath.isEmpty ? "settings.brew.custom-homebrew-path.is-using-default-path" : "settings.brew.custom-homebrew-path.is-using-custom-path")
                            
                            Button {
                                print("Ahoj")
                            } label: {
                                Text("settings.brew.custom-homebrew-path.select")
                            }
                        }
                    } label: {
                        Text("settings.brew.custom-homebrew-path")
                    }

                }
                .disabled(!allowAdvancedHomebrewSettings)
            }
        }
    }
}
