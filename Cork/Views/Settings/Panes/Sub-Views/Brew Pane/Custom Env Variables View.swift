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
import FactoryKit
import ButtonKit
import CorkModels

struct CustomEnvVariablesView: View
{
    @Injected(\.shellManager) var shellManager
    @InjectedObservable(\.appState) var appState
    
    @Default(.allowAdvancedHomebrewSettings) var allowAdvancedHomebrewSettings: Bool
    @Default(.customEnvVariables) var customEnvVariables: [EnvironmentVariable]
    
    @Default(.showInheritedEnvVariables) var showInheritedEnvVariables: Bool
    @Default(.showUserEnvVariables) var showUserEnvVariables: Bool
    @Default(.showMandatoryEnvVariables) var showMandatoryEnvVariables: Bool
    
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    @State private var isShowingCustomEnvVarAdditionPopover: Bool = false
    @State private var customVariableKey: String = ""
    @State private var customVariableValue: String = ""
    
    @State private var userEnvVariables: [EnvironmentVariable]?
    @State private var processEnvVariables: [EnvironmentVariable]?
    @State private var mandatoryEnvVariables: [EnvironmentVariable]?
    
    @State private var searchText: String = ""
    
    var shownUserEnvVariables: [EnvironmentVariable]
    {
        guard let userEnvVariables else
        {
            return .init()
        }
        
        guard !searchText.isEmpty else {
            return userEnvVariables
        }
        
        return userEnvVariables.filter({ $0.key.localizedCaseInsensitiveContains(searchText) || $0.value.localizedCaseInsensitiveContains(searchText) })
    }
    
    var shownProcessVariables: [EnvironmentVariable]
    {
        guard let processEnvVariables else {
            return .init()
        }
        
        guard !searchText.isEmpty else {
            return processEnvVariables
        }
        
        return processEnvVariables.filter({ $0.key.localizedCaseInsensitiveContains(searchText) || $0.value.localizedCaseInsensitiveContains(searchText) })
    }

    var shownMandatoryVariables: [EnvironmentVariable]
    {
        guard let mandatoryEnvVariables else {
            return .init()
        }
        
        guard !searchText.isEmpty else {
            return mandatoryEnvVariables
        }
        
        return mandatoryEnvVariables.filter({ $0.key.localizedCaseInsensitiveContains(searchText) })
    }
    
    var body: some View
    {
        if allowAdvancedHomebrewSettings
        {
            DisclosureGroup("settings.brew.custom-env-variables.dropdown")
            {
                VStack(alignment: .leading)
                {
                    Defaults.Toggle(String(localized: "settings.brew.custom-env-variables.show-user-variables.toggle"), key: .showUserEnvVariables)
                    Defaults.Toggle(String(localized: "settings.brew.custom-env-variables.show-inherited-variables.toggle"), key: .showInheritedEnvVariables)
                    
                    Defaults.Toggle(String(localized: "settings.brew.custom-env-variables.show-mandatory-variables.toggle"), key: .showMandatoryEnvVariables)
                }
                .padding(.leading)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                Divider()
                
                CustomSearchField(search: $searchText, customPromptText: nil)
                Table(of: EnvironmentVariable.self)
                {
                    TableColumn("settings.brew.custom-env.variables.key.label", value: \.key)
                    TableColumn("settings.brew.custom-env.variables.value.label", value: \.value)
                } rows: {
                    /*
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
                        /*
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
                         */
                    }
                     
                     */
                    
                    if showUserEnvVariables
                    {
                        Section
                        {
                            if !shownUserEnvVariables.isEmpty
                            {
                                ForEach(shownUserEnvVariables)
                                { userEnvValue in
                                    TableRow(userEnvValue)
                                }
                            }
                        } header: {
                            Text("settings.brew.custom-env.variables.user-inherited.label")
                        }
                    }
                    

                    if showInheritedEnvVariables
                    {
                        Section
                        {
                            if !shownProcessVariables.isEmpty
                            {
                                ForEach(shownProcessVariables)
                                { inheritedEnvVariable in
                                    TableRow(inheritedEnvVariable)
                                }
                            }
                        } header: {
                            Text("settings.brew.custom-env.variables.inherited.label")
                        }
                    }
                    
                    if showMandatoryEnvVariables
                    {
                        Section
                        {
                            if !shownMandatoryVariables.isEmpty
                            {
                                ForEach(shownMandatoryVariables)
                                { mandatoryEnvVariable in
                                    TableRow(mandatoryEnvVariable)
                                }
                            }
                        } header: {
                            Text("settings.brew.custom-env.variables.mandatory.label")
                        }
                    }
                }
                .frame(minHeight: 200, maxHeight: 400)
                .tableStyle(.bordered(alternatesRowBackgrounds: true))
                .animation(.easeInOut, value: showInheritedEnvVariables)
                .task
                {
                    self.userEnvVariables = try? await shellManager.userEnvironmentObjects()
                    
                    self.processEnvVariables = await shellManager.processEnvironmentObjects()
                    
                    self.mandatoryEnvVariables = await shellManager.mandatoryEnvironmentObjects()
                }
                
                AsyncButton
                {
                    do
                    {
                        let consolidatedEnvironmentVariables: [EnvironmentVariable] = try await shellManager.combinedEnvironmentObjects()
                        
                        openWindow(id: .environmentPreviewWindowID, value: consolidatedEnvironmentVariables)
                    }
                    catch let objectRetrievalError
                    {
                        appState.showAlert(errorToShow: .couldNotConstructConsolidatedEnvironmentVariables(error: objectRetrievalError.localizedDescription))
                    }
                } label: {
                    Text("action.preview-env-variables")
                }

            }
        }
    }
}
