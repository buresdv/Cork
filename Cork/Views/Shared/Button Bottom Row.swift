//
//  Button Row.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import SwiftUI

struct ButtonBottomRow<Content: View>: View
{
    @ViewBuilder var content: Content

    var body: some View
    {
        Spacer()

        HStack(alignment: .center)
        {
            content
        }
        .padding()
    }
}
