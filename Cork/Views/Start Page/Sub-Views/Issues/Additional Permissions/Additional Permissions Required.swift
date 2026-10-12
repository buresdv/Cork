//
//  Additional Permissions Required.swift
//  Cork
//
//  Created by David Bureš - P on 17.09.2026.
//

import SwiftUI
import FactoryKit
import CorkModels

struct AdditionalPermissionsRequired: View
{
    @InjectedObservable(\.appState) var appState: AppState
    
    var body: some View
    {
        GroupBoxHeadlineGroupWithArbitraryImageAndContent(image: .init(systemName: "hand.raised"))
        {
            HStack(alignment: .center, spacing: 5)
            {
                Text("start-page.additional-permissions.title")
                    .font(.headline)
                
                Spacer()
                
                Button
                {
                    appState.showSheet(ofType: .fixFullDiskAccessPermissions)
                } label: {
                    Label("action.fix-permissions", systemImage: "hand.thumbsup")
                        .labelStyle(.titleOnly)
                }
            }
        }
    }
}
