//
//  Self-Compiled.swift
//  Cork
//
//  Created by David Bureš on 13.05.2024.
//

import SwiftUI

struct Licensing_SelfCompiledView: View
{
    @AppStorage("demoActivatedAt") var demoActivatedAt: Date?
    @AppStorage("hasFinishedLicensingWorkflow") var hasFinishedLicensingWorkflow: Bool = false

    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var appState: AppState

    var body: some View
    {
        VStack(alignment: .center, spacing: 15)
        {
            Image(systemName: "wrench.and.screwdriver")
                .resizable()
                .foregroundColor(.purple)
                .frame(width: 50, height: 50)

            Text("licensing.self-compiled.title")
                .font(.title)

            Text("licensing.self-compiled.body")
                .multilineTextAlignment(.center)

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
        }
    }
}
