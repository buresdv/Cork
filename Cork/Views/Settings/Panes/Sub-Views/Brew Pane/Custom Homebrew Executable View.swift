//
//  Custom Homebrew Executable View.swift
//  Cork
//
//  Created by David Bureš on 22.05.2024.
//

import SwiftUI
import CorkShared
import Defaults

struct CustomHomebrewExecutableView: View
{
    @Default(.customHomebrewPath) var customHomebrewPath: URL?
    @Default(.allowAdvancedHomebrewSettings) var allowAdvancedHomebrewSettings: Bool

    @EnvironmentObject var settingsState: SettingsState

    @State private var isShowingCustomLocationDialog: Bool = false
    @State private var isShowingCustomLocationConfirmation: Bool = false

    var body: some View
    {
        Form
        {
            Section
            {
                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        GroupBox
                        {
                            PathControl(urlToShow: URL(filePath: AppConstants.shared.brewExecutablePath.path), style: .standard, width: 295)
                                .disabled(true)
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

                            if customHomebrewPath != nil
                            {
                                Button
                                {
                                    customHomebrewPath = nil
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
        .onChange(of: allowAdvancedHomebrewSettings, perform: { newValue in
            if newValue == false
            {
                if customHomebrewPath != nil
                {
                    customHomebrewPath = nil
                }
            }
        })
        .fileImporter(
            isPresented: $isShowingCustomLocationDialog,
            allowedContentTypes: [.unixExecutable],
            allowsMultipleSelection: false
        )
        { result in
            switch result
            {
            case .success(let success):
                if success.first!.lastPathComponent == "brew"
                {
                    guard let selectedCustomHomebrewPath = success.first else
                    {
                        AppConstants.shared.logger.error("Failed while getting selected custom Homebrew executable")
                        return
                    }
                    
                    AppConstants.shared.logger.info("Valid brew executable: \(selectedCustomHomebrewPath.path)")
                    
                    customHomebrewPath = selectedCustomHomebrewPath
                }
                else
                {
                    AppConstants.shared.logger.error("Not a valid brew executable")

                    settingsState.alertType = .customHomebrewLocationNotABrewExecutable(executablePath: success.first!.path)
                    settingsState.isShowingAlert = true
                }
            case .failure(let failure):
                AppConstants.shared.logger.error("Failure: \(failure)")

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
