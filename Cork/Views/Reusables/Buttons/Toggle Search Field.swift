//
//  Toggle Search Field.swift
//  Cork
//
//  Created by David Bureš - P on 07.01.2026.
//

import SwiftUI

struct ToggleSearchFieldButton: View
{
    
    @Binding var isShowingSearchField: Bool
    
    var body: some View
    {
        Button
        {
            isShowingSearchField.toggle()
        } label: {
            Label("action.show-search-field", systemImage: "magnifyingglass")
                .labelStyle(.iconOnly)
        }
        .accessibilityHint(isShowingSearchField ? Text("action.hide-search-field.hint") : Text("action.show-search-field.hint"))
        .buttonStyle(.accessoryBar)
    }
}
