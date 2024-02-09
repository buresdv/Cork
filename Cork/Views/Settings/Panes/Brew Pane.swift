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

    @EnvironmentObject var settingsState: SettingsState

    @State private var isPerformingBrewAnalyticsChangeCommand: Bool = false
    @State private var isShowingCustomLocationDialog: Bool = false
    @State private var isShowingCustomLocationConfirmation: Bool = false

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

                VStack(alignment: .center)
                {
                    Toggle(isOn: $allowAdvancedHomebrewSettings, label: {
                        Text("settings.brew.enable-advanced-settings")
                    })
                    .toggleStyle(.switch)

                    Text("settings.brew.custom-homebrew-path.will-not-bother-me-with-support")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Form
                {
                    Section
                    {
                        LabeledContent
                        {
                            VStack(alignment: .leading)
                            {
                                if customHomebrewPath.isEmpty
                                {
                                    Text("settings.brew.custom-homebrew-path.is-using-default-location")
                                }
                                else
                                {
                                    Text("settings.brew.custom-homebrew-path.is-using-custom-location-\(customHomebrewPath)")
                                }

                                Spacer()

                                HStack
                                {
                                    Button
                                    {
                                        isShowingCustomLocationConfirmation = true
                                    } label: {
                                        Text("settings.brew.custom-homebrew-path.select")
                                    }
                                    
                                    if !customHomebrewPath.isEmpty
                                    {
                                        Button
                                        {
                                            customHomebrewPath = ""
                                        } label: {
                                            Text("settings.brew.custom-homebrew-path.reset")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text("settings.brew.custom-homebrew-path")
                        }
                    }
                }
                .disabled(!allowAdvancedHomebrewSettings)
                .fileImporter(
                    isPresented: $isShowingCustomLocationDialog,
                    allowedContentTypes: [.unixExecutable],
                    allowsMultipleSelection: false
                )
                { result in
                    switch result
                    {
                    case let .success(success):
                        if success.first!.lastPathComponent == "brew"
                        {
                            print("Valid brew executable: \(success.first!.path)")

                            customHomebrewPath = success.first!.path
                        }
                        else
                        {
                            print("Not a valid brew executable")

                            settingsState.alertType = .customHomebrewLocationNotABrewExecutable(executablePath: success.first!.path)
                            settingsState.isShowingAlert = true
                        }
                    case let .failure(failure):
                        print("Failure: \(failure)")

                        settingsState.alertType = .customHomebrewLocationNotAnExecutableAtAll
                        settingsState.isShowingAlert = true
                    }
                }
                .confirmationDialog(
                    Text("settings.brew.custom-homebrew-path.confirmation.title"),
                    isPresented: $isShowingCustomLocationConfirmation
                )
                {
                    Button
                    {
                        isShowingCustomLocationDialog = true
                    } label: {
                        Text("settings.brew.custom-homebrew-path.confirmation.confirm")
                    }
                } message: {
                    Text("settings.brew.custom-homebrew-path.confirmation.message")
                }
            }
        }
        .onChange(of: allowAdvancedHomebrewSettings, perform: { newValue in
            if newValue == false
            {
                if !customHomebrewPath.isEmpty
                {
                    customHomebrewPath = ""
                }
            }
        })
    }
}
