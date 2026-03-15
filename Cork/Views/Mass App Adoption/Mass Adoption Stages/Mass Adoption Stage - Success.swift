//
//  Mass Adoption Stage - Success.swift
//  Cork
//
//  Created by David Bureš - P on 07.10.2025.
//

import SwiftUI
import Defaults
import CorkNotifications
import FactoryKit
import CorkModels

struct MassAdoptionStage_Success: View
{
    @Default(.notifyAboutMassAdoptionResults) var notifyAboutMassAdoptionResults: Bool
    
    @InjectedObservable(\.appState) var appState: AppState
    
    var body: some View
    {
        DisappearableSheet
        {
            ComplexWithIcon(systemName: "checkmark.seal")
            {
                HeadlineWithSubheadline(
                    headline: "mass-adoption.finished",
                    subheadline: "mass-adoption.finished.description",
                    alignment: .leading
                )
            }
        }
        .onAppear {
            if notifyAboutMassAdoptionResults
            {
                sendNotification(
                    title: "mass-adoption.finished",
                    body: "mass-adoption.finished-successfully.message"
                )
            }
        }
    }
}
