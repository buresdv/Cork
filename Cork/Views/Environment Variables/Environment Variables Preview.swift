//
//  Environment Variables Preview.swift
//  Cork
//
//  Created by David Bureš - P on 13.10.2026.
//

import SwiftUI
import CorkShared
import CorkTerminalFunctions
import FactoryKit

struct EnvironmentVariablesPreview: View
{
    let environmentVariablesToPreview: [EnvironmentVariable]
    
    private enum EnvironmentVariablePreviewType: LocalizedStringKey, Identifiable, CaseIterable
    {
        var id: String { self.rawValue.stringKey! }
        
        case asString = "settings.brew.custom-env.variables.window.display-as-string.picker.label"
        case asListOfObjects = "settings.brew.custom-env.variables.window.display-as-objects.picker.label"
    }
    
    @State private var environmentVariablePreviewType: EnvironmentVariablePreviewType = .asString
    
    @State private var searchString: String = ""
    
    var body: some View
    {
        NavigationStack
        {
            Group
            {
                switch environmentVariablePreviewType
                {
                case .asString:
                    EnvironmentVariablesPreview_AsString(
                        environmentVariablesToPreview: environmentVariablesToPreview,
                        searchString: searchString
                    )
                case .asListOfObjects:
                    EnvironmentVariablesPreview_AsObjects(
                        environmentVariablesToPreview: environmentVariablesToPreview,
                        searchString: searchString
                    )
                }
            }
            .navigationTitle("settings.brew.custom-env.variables.window.title")
            .navigationSubtitle("settings.brew.custom-env.variables.window.subtitle.includes-\(environmentVariablesToPreview.count)-variables")
            .padding()
            .searchable(text: $searchString)
            .toolbar
            {
                ToolbarItem(placement: .secondaryAction)
                {
                    Picker(selection: $environmentVariablePreviewType)
                    {
                        ForEach(EnvironmentVariablePreviewType.allCases)
                        { previewType in
                            Text(previewType.rawValue)
                                .tag(previewType)
                        }
                    } label: {
                        Text("Hello, World!")
                    }

                }
            }
        }
    }
    
}

private struct EnvironmentVariablesPreview_AsString: View
{
    let environmentVariablesToPreview: [EnvironmentVariable]
    
    let searchString: String
    
    private var convertedVariables: AttributedString
    {
        let convertedVariables: [String: String] = .init(environmentVariables: environmentVariablesToPreview)
        
        var variablesAsAttributedString: AttributedString = AttributedString(convertedVariables.description)
        
        if let range = variablesAsAttributedString.range(of: searchString)
        {
            variablesAsAttributedString[range].backgroundColor = .yellow
            variablesAsAttributedString[range].strokeColor = .black
        }
        
        return variablesAsAttributedString
    }
    
    var body: some View
    {
        Text(convertedVariables)
    }
}

private struct EnvironmentVariablesPreview_AsObjects: View
{
    let environmentVariablesToPreview: [EnvironmentVariable]
    
    let searchString: String
    
    var displayedVariables: [EnvironmentVariable]
    {
        guard !searchString.isEmpty else
        {
            return environmentVariablesToPreview
        }
        
        return environmentVariablesToPreview.filter({ $0.key.localizedCaseInsensitiveContains(searchString) || $0.value.localizedCaseInsensitiveContains(searchString) })
    }
    
    var body: some View
    {
        Table(displayedVariables)
        {
            TableColumn("settings.brew.custom-env.variables.key.label", value: \.key)
            
            TableColumn("settings.brew.custom-env.variables.value.label", value: \.value)
        }
    }
}
