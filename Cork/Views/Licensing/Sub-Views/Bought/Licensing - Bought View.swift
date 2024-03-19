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
    
    @EnvironmentObject var appState: AppState
    
    var body: some View
    {
        VStack(alignment: .center, spacing: 20)
        {   
            Text("licensing.bought.title")
                .font(.title)
            
            Text("licensing.bought.body")
            
            HStack(alignment: .center, spacing: 20)
            {
                Button
                {
                    hasFinishedLicensingWorkflow = true // Make it so that the sheet doesn't show up all the time anymore
                } label: {
                    Text("action.close")
                }
            }
        }
        .padding()
        .onAppear
        {
            demoActivatedAt = nil // Reset the demo, since it won't be needed anymore
            
            hasValidatedEmail = true
        }
    }
}

