//
//  Show Package Insights Button.swift
//  Cork
//
//  Created by David Bureš - P on 24.10.2026.
//

import SwiftUI

struct ShowPackageInsightsButton: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    var body: some View
    {
        Button {
            openWindow(id: .packageInsightsWindowID)
        } label: {
            Label("action.open-package-insights", image: "custom.shippingbox.viewfinder")
        }

    }
}
