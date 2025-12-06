//
//  Delete Cached Downloads Button.swift
//  Cork
//
//  Created by David Bureš - Virtual on 12.06.2025.
//

import SwiftUI
import CorkModels

struct DeleteCachedDownloadsButton: View
{
    let appState: AppState
    
    var body: some View
    {
        Button
        {
            appState.showSheet(ofType: .maintenance(fastCacheDeletion: true))
        } label: {
            Label("start-page.cached-downloads.action", image: "custom.brain.slash")
        }
    }
}
