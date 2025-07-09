//
//  Pin Unpin Button.swift
//  Cork
//
//  Created by David Bureš - P on 09.07.2025.
//

import SwiftUI
import ButtonKit

struct PinUnpinButton: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    
    var package: BrewPackage
    
    var body: some View
    {
        if package.type == .formula
        {
            AsyncButton
            {
                await package.performPinnedStatusChangeAction(appState: appState, brewData: brewData)
            } label: {
                Text(package.isPinned ? "package-details.action.unpin-version-\(package.versions.formatted(.list(type: .and)))" : "package-details.action.pin-version-\(package.versions.formatted(.list(type: .and)))")
            }
            .asyncButtonStyle(.leading)
            .disabledWhenLoading()
        }
    }
}
