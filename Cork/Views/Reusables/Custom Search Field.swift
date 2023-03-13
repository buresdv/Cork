//
//  Custom Search Field.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import Foundation
import SwiftUI

struct CustomSearchField: NSViewRepresentable {
    
    @Binding var search: String
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: CustomSearchField
        
        init(_ parent: CustomSearchField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ notification: Notification) {
            guard let searchField = notification.object as? NSSearchField else {
                return
            }
            self.parent.search = searchField.stringValue
        }
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField(frame: .zero)
        return searchField
    }
    
    
    func updateNSView(_ searchField: NSSearchField, context: Context) {
        searchField.stringValue = search
        searchField.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
