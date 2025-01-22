//
//  Error Inspector.swift
//  Cork
//
//  Created by David Bureš - P on 20.01.2025.
//

import SwiftUI

struct ErrorInspector: View
{  
    let errorText: String

    var body: some View
    {
        NavigationStack
        {
            TextEditor(text: .constant(errorText))
                .navigationTitle("error-inspector.title")
                .frame(minWidth: 300, minHeight: 200)
        }
        .modify
        { viewProxy in
            if #available(macOS 15, *)
            {
                viewProxy
                    .windowMinimizeBehavior(.disabled)
            }
        }
    }
}
