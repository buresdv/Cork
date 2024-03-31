//
//  Tap Features Category.swift
//  Cork
//
//  Created by David Bureš on 25.10.2023.
//

import SwiftUI

struct OnboardingTapFeaturesCategory: View
{
    
    let onboardingSetupLevelNumber: Float
    
    var body: some View
    {
        LabeledContent 
        {
            VStack(alignment: .trailing, spacing: 3)
            {
                // Basic
                if onboardingSetupLevelNumber >= 0
                {
                    Text("onboarding.feature.tap-details")
                }
                
                // Slightly basic
                if onboardingSetupLevelNumber >= 1
                {
                    
                }
                
                // Balanced
                if onboardingSetupLevelNumber >= 2
                {
                    
                }
                
                // Slightly advanced
                if onboardingSetupLevelNumber >= 3
                {
                    
                }
                
                // Advanced
                if onboardingSetupLevelNumber >= 4
                {
                    
                }
            }
        } label: {
            Text("onboarding.details.section.tap-features")
        }
    }
}
