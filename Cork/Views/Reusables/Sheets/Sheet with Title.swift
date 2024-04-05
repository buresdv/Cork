//
//  SwiftUIView.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct SheetWithTitle<Content: View>: View
{
    let title: LocalizedStringKey

    @ViewBuilder var sheetContent: Content

    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text(title)
                .font(.headline)

            sheetContent
        }
        .frame(minWidth: 300)
    }
}
