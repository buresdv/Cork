//
//  Disappearable Sheet.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct DisappearableSheet<Content: View>: View
{
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss: DismissAction

    @ViewBuilder var sheetContent: Content

    var body: some View
    {
        sheetContent
            .onAppear
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3)
                {
                    appState.dismissSheet()
                }
            }
    }
}
