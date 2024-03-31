//
//  Disappearable Sheet.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct DisappearableSheet<Content: View>: View
{
    @Environment(\.dismiss) var dismiss

    @ViewBuilder var sheetContent: Content

    var body: some View
    {
        sheetContent
            .onAppear
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3)
                {
                    dismiss()
                }
            }
    }
}
