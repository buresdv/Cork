//
//  Custom Search Field.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import SwiftUI

struct CustomSearchField: NSViewRepresentable
{
    @Binding var search: String
    
    var isFocused: Binding<Bool>? = nil
    
    let customPromptText: String?

    class Coordinator: NSObject, NSSearchFieldDelegate
    {
        var parent: CustomSearchField
        
        // Track the last focus value that was actually applied, only fire when `makeFirstResponder` changes to get rid of that fuckass bug that made the whole field refocus on every keystroke
        var lastAppliedFocusState: Bool = false

        init(_ parent: CustomSearchField)
        {
            self.parent = parent
        }

        func controlTextDidChange(_ notification: Notification)
        {
            guard let searchField = notification.object as? NSSearchField else { return }
            parent.search = searchField.stringValue
        }

        func controlTextDidBeginEditing(_: Notification)
        {
            parent.isFocused?.wrappedValue = true
            lastAppliedFocusState = true
        }

        func controlTextDidEndEditing(_: Notification)
        {
            parent.isFocused?.wrappedValue = false
            lastAppliedFocusState = false
        }
    }

    func makeNSView(context: Context) -> NSSearchField
    {
        let searchField: NSSearchField = .init(frame: .zero)
        searchField.delegate = context.coordinator

        if let customPromptText
        {
            searchField.placeholderString = NSLocalizedString(customPromptText, comment: "")
        }

        return searchField
    }

    func updateNSView(_ searchField: NSSearchField, context: Context)
    {

        guard let isFocused = isFocused else { return }

        let shouldBeFocused = isFocused.wrappedValue

        // Get rid of that fuckass bug that cleared the text field on every keystroke
        guard shouldBeFocused != context.coordinator.lastAppliedFocusState else { return }

        context.coordinator.lastAppliedFocusState = shouldBeFocused

        if shouldBeFocused
        {
            DispatchQueue.main.async
            {
                searchField.window?.makeFirstResponder(searchField)
            }
        }
        
    }

    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }
}
