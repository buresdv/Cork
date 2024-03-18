//
//  Licensing - Not Bought Or Activated View.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import SwiftUI

struct Licensing_NotBoughtOrActivatedView: View
{
    @AppStorage("demoActivatedAt") var demoActivatedAt: Date?
    
    @State private var emailFieldContents: String = ""
    
    var isDemoButtonDisabled: Bool
    { // Disable the Demo button if the user activated it before, and if it has been at least 7 days since the user activated the demo
        if let demoActivatedAt
        {
            var timeIntervalSinceDemoWasActivated: TimeInterval = demoActivatedAt.timeIntervalSince(.now)
            
            if timeIntervalSinceDemoWasActivated > AppConstants.demoLengthInSeconds
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    var body: some View
    {
        VStack(alignment: .center, spacing: 20)
        {
            Text("licensing.not-bought-or-activated.title")
                .font(.title)
            
            Text("licensing.not-bought-or-activated.body")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .fixedSize()
            
            VStack(alignment: .leading, spacing: 5)
            {
                Text("licensing.email")
                
                TextField(text: $emailFieldContents, prompt: Text("licensing.email-field.prompt")) {
                    Text("licensing.email")
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 10)
            {
                HStack(alignment: .firstTextBaseline, spacing: 5)
                {
                    ButtonThatOpensWebsites(websiteURL: URL(string: "https://corkmac.app/create-checkout-session.php")!, buttonText: "action.buy")
                        .labelStyle(.titleOnly)
                    
                    Text("licensing.price.copy")
                        .font(.subheadline)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                }
                
                Spacer()
                
                Button
                {
                    demoActivatedAt = .now
                } label: {
                    Text("action.activate-demo")
                }
                .disabled(isDemoButtonDisabled)
                
                Button
                {
                    
                } label: {
                    Text("action.check-license")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(emailFieldContents.isEmpty || !emailFieldContents.contains("@") || !emailFieldContents.contains("."))
            }
        }
        .padding()
        .onAppear
        {
            if let demoActivatedAt
            {
                var timeIntervalSinceDemoWasActivated: TimeInterval = demoActivatedAt.timeIntervalSince(.now)
                AppConstants.logger.debug("Time interval since demo was activated: \(timeIntervalSinceDemoWasActivated, privacy: .public)")
            }
        }
    }
}
