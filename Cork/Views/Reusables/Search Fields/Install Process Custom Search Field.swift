//
//  Install Process Custom Search Field.swift
//  Cork
//
//  Created by David Bureš on 22.05.2024.
//

import Foundation

import Foundation
import SwiftUI

struct InstallProcessCustomSearchField: NSViewRepresentable
{
    @Binding var search: String
    @Binding var isFocused: Bool
    
    let customPromptText: String?
    
    var onSubmit: (() -> Void)?
    
    class Coordinator: NSObject, NSSearchFieldDelegate
    {
        var parent: InstallProcessCustomSearchField
        var onSubmit: (() -> Void)?
        
        init(parent: InstallProcessCustomSearchField, onSubmit: (() -> Void)?) {
            self.parent = parent
            self.onSubmit = onSubmit
        }
        
        func controlTextDidChange(_ notification: Notification)
        {
            guard let searchField = notification.object as? NSSearchField
            else
            {
                return
            }
            parent.search = searchField.stringValue
        }
        
        func controlTextDidBeginEditing(_: Notification)
        {
            parent.isFocused = true
            print("Search field became focused")
        }
        
        func controlTextDidEndEditing(_: Notification)
        {
            parent.isFocused = false
            print("Search field became unfocused")
        }
        
        func searchFieldDidStartSearching(_ sender: NSSearchField) {
            print("Field started searching")
            onSubmit?()
        }
    }
    
    func makeNSView(context _: Context) -> NSSearchField
    {
        let searchField = NSSearchField(frame: .zero)
        
        if let customPromptText
        {
            searchField.placeholderString = NSLocalizedString(customPromptText, comment: "")
        }
        
        /// Focus the search field on appear
        DispatchQueue.main.async
        {
            if let window = searchField.window
            {
                if window.firstResponder != searchField
                {
                    window.makeFirstResponder(searchField)
                }
            }
        }
        
        return searchField
    }
    
    func updateNSView(_ searchField: NSSearchField, context: Context)
    {
        searchField.stringValue = search
        searchField.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator
    {
        return Coordinator(parent: self, onSubmit: onSubmit)
    }
}
