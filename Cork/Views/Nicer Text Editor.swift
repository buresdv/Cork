//
//  Nicer Text Editor.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import SwiftUI

struct NicerTextEditor: View
{
    @Binding var text: String

    var body: some View
    {
        TextEditor(text: $text)
            .font(.body)
            .background(Color.white)
            .padding(5)
            .border(Color(nsColor: NSColor.separatorColor))
    }
}

