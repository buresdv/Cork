//
//  Extras Category.swift
//  Cork
//
//  Created by David Bureš on 25.10.2023.
//

import SwiftUI

struct OnboardingExtrasCategory: View
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
                    Text("onboarding.feature.search")
                    Text("onboarding.feature.tagging")
                }
                
                // Slightly basic
                if onboardingSetupLevelNumber >= 1
                {
                    Text("onboarding.feature.compatibility-checking")
                }
                
                // Balanced
                if onboardingSetupLevelNumber >= 2
                {
                    Text("onboarding.feature.notifications")
                }
                
                // Slightly advanced
                if onboardingSetupLevelNumber >= 3
                {
                    Text("onboarding.feature.menu-bar")
                }
                
                // Advanced
                if onboardingSetupLevelNumber >= 4
                {
                    
                }
            }
        } label: {
            Text("onboarding.details.section.extras")
        }
    }
}
