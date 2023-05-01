//
//  Dismiss Sheet Button.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct DismissSheetButton: View
{
    @Binding var isShowingSheet: Bool
    @State var customButtonText: LocalizedStringKey?

    var body: some View
    {
        Button
        {
            isShowingSheet.toggle()
        } label: {
            if let customButtonText
            {
                Text(customButtonText)
            }
            else
            {
                Text("action.cancel")
            }
        }
        .keyboardShortcut(.cancelAction)
    }
}
