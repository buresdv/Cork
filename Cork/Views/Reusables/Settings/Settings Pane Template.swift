//
//  Settings Pane Template.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct SettingsPaneTemplate<Content: View>: View
{
    @ViewBuilder var paneContent: Content

    var body: some View
    {
        paneContent
            .strechedPickers()
            .labeledContentStyle(.automatic)
            .frame(minWidth: 470, minHeight: 50)
            .fixedSize()
            .modify
            { viewProxy in
                if #available(macOS 26, *)
                {
                    viewProxy
                        .scenePadding()
                }
                else
                {
                    viewProxy
                        .padding()
                }
            }
    }
}
