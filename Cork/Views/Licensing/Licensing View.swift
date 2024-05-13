//
//  Licensing View.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import SwiftUI

struct LicensingView: View
{
    @AppStorage("demoActivatedAt") var demoActivatedAt: Date?
    @AppStorage("hasValidatedEmail") var hasValidatedEmail: Bool = false
    
    @EnvironmentObject var appState: AppState
    
    var body: some View
    {
        VStack
        {
            switch appState.licensingState {
                case .notBoughtOrHasNotActivatedDemo:
                    Licensing_NotBoughtOrActivatedView()
                case .demo:
                    Licensing_DemoView()
                case .bought:
                    Licensing_BoughtView()
                case .selfCompiled:
                    Licensing_SelfCompiledView()
            }
        }
        .onAppear
        {
            #if SELF_COMPILED
            appState.licensingState = .selfCompiled
            #else
            AppConstants.logger.debug("Has validated email? \(hasValidatedEmail ? "YES" : "NO")")
            
            if hasValidatedEmail
            {
                appState.licensingState = .bought
            }
            else
            {
                if let demoActivatedAt
                {
                    if ((demoActivatedAt.timeIntervalSinceNow) + AppConstants.demoLengthInSeconds) > 0
                    { // Check if there is still time on the demo
                        appState.licensingState = .demo
                    }
                    else
                    {
                        appState.licensingState = .notBoughtOrHasNotActivatedDemo
                    }
                }
            }
            #endif
        }
    }
}
