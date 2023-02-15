//
//  Settings Pane Template.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct SettingsPaneTemplate<Content: View>: View {
    
    @ViewBuilder var paneContent: Content
    
    var body: some View {
        paneContent
            .padding()
            .frame(minWidth: 300, minHeight: 50)
    }
}
