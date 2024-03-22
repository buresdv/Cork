//
//  Licensing - Bought View.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import SwiftUI

struct Licensing_BoughtView: View
{
    
    @AppStorage("demoActivatedAt") var demoActivatedAt: Date?
    @AppStorage("hasFinishedLicensingWorkflow") var hasFinishedLicensingWorkflow: Bool = false
    @AppStorage("hasValidatedEmail") var hasValidatedEmail: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var appState: AppState
    
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

