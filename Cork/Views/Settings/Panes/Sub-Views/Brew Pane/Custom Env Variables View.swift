//
//  Custom Env Variables View.swift
//  Cork
//
//  Created by David Bureš - P on 30.04.2026.
//

import CorkShared
import CorkTerminalFunctions
import Defaults
import SwiftUI

struct CustomEnvVariablesView: View
{
    @Default(.allowAdvancedHomebrewSettings) var allowAdvancedHomebrewSettings: Bool
    @Default(.customEnvVariables) var customEnvVariables: [EnvironmentVariable]
    @Default(.showInheritedEnvVariables) var showInheritedEnvVariables: Bool

    @State private var isShowingCustomEnvVarAdditionPopover: Bool = false
    @State private var customVariableKey: String = ""
    @State private var customVariableValue: String = ""

    let inheritedEnvVariables: [EnvironmentVariable] = .init(environment: ProcessInfo.processInfo.environment)

    var body: some View
    {
        if allowAdvancedHomebrewSettings
        {
            DisclosureGroup("settings.brew.custom-env-variables.dropdown")
            {
                Defaults.Toggle(String(localized: "settings.brew.custom-env-variables.show-inherited-variables.toggle"), key: .showInheritedEnvVariables)

                Table(of: EnvironmentVariable.self)
                {
                    TableColumn("settings.brew.custom-env.variables.key.label", value: \.key)
                    TableColumn("settings.brew.custom-env.variables.value.label", value: \.value)
                } rows: {
                    Section
                    {
                        ForEach(customEnvVariables)
                        { customEnvVariable in
                            TableRow(customEnvVariable)
                                .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        customEnvVariables.removeAll { $0.id == customEnvVariable.id }
                                    } label: {
                                        Label("action.delete", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        HStack(alignment: .center)
                        {
                            Text("settings.brew.custom-env.variables.custom.label")

                            Spacer()

                            Button
                            {
                                isShowingCustomEnvVarAdditionPopover.toggle()
                            } label: {
                                Label("action.add", systemImage: "plus")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .sheet(isPresented: $isShowingCustomEnvVarAdditionPopover)
                        {
                            SheetTemplate(isShowingTitle: false)
                            {
                                Form
                                {
                                    TextField("settings.brew.custom-env.variables.add-custom-variable.key.label", text: $customVariableKey, prompt: Text("settings.brew.custom-env.variables.add-custom-variable.key.prompt"))

                                    TextField("settings.brew.custom-env.variables.add-custom-variable.value.label", text: $customVariableValue, prompt: Text("settings.brew.custom-env.variables.add-custom-variable.value.prompt"))
                                }
                                .padding()
                                .toolbar
                                {
                                    ToolbarItem(placement: .primaryAction)
                                    {
                                        Button(role: .destructive)
                                        {
                                            customEnvVariables.append(.init(key: customVariableKey, value: customVariableValue))
                                            
                                            customVariableKey = ""
                                            customVariableValue = ""
                                        } label: {
                                            Label("action.add", systemImage: "plus")
                                                .labelStyle(.titleOnly)
                                        }
                                        .keyboardShortcut(.defaultAction)
                                        .disabled(customVariableKey.isEmpty && customVariableValue.isEmpty)
                                    }

                                    ToolbarItem(placement: .cancellationAction)
                                    {
                                        DismissSheetButton()
                                    }
                                }
                            }
                        }
                    }

                    if showInheritedEnvVariables
                    {
                        Section
                        {
                            ForEach(inheritedEnvVariables)
                            { inheritedEnvVariable in
                                TableRow(inheritedEnvVariable)
                            }
                        } header: {
                            Text("settings.brew.custom-env.variables.inherited.label")
                        }
                    }
                }
                .frame(minHeight: 200, maxHeight: 400)
                .tableStyle(.bordered(alternatesRowBackgrounds: true))
                .animation(.easeInOut, value: showInheritedEnvVariables)
            }
        }
    }
}
