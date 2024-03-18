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
            }
        }
        .onAppear
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
    }
}

#Preview
{
    LicensingView()
}
