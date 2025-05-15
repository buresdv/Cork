//
//  Licensing - Bought View.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import SwiftUI
import Defaults

struct Licensing_BoughtView: View
{
    @Default(.demoActivatedAt) var demoActivatedAt: Date?
    @Default(.hasFinishedLicensingWorkflow) var hasFinishedLicensingWorkflow: Bool
    @Default(.hasValidatedEmail) var hasValidatedEmail: Bool

    @Environment(\.dismiss) var dismiss: DismissAction

    @Environment(AppState.self) var appState: AppState

    var body: some View
    {
        VStack(alignment: .center, spacing: 15)
        {
            Image(systemName: "checkmark.seal")
                .resizable()
                .foregroundColor(.green)
                .frame(width: 50, height: 50)

            Text("licensing.bought.title")
                .font(.title)

            Text("licensing.bought.body")

            HStack(alignment: .center, spacing: 20)
            {
                Button
                {
                    dismiss()
                    if !hasFinishedLicensingWorkflow
                    {
                        hasFinishedLicensingWorkflow = true // Make it so that the sheet doesn't show up all the time anymore
                    }
                } label: {
                    Text("action.close")
                }
                .keyboardShortcut(.cancelAction)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .fixedSize()
        .onAppear
        {
            demoActivatedAt = nil // Reset the demo, since it won't be needed anymore

            hasValidatedEmail = true
        }
    }
}
