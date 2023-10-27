//
//  Package Features Category.swift
//  Cork
//
//  Created by David Bureš on 25.10.2023.
//

import SwiftUI

struct OnboardingPackageFeaturesCategory: View
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
                    Text("onboarding.feature.package-details")
                }
                
                // Slightly basic
                if onboardingSetupLevelNumber >= 1
                {
                    Text("onboarding.feature.package-descriptions-in-search")
                }
                
                // Balanced
                if onboardingSetupLevelNumber >= 2
                {
                    Text("onboarding.feature.detailed-caveats")
                }
                
                // Slightly advanced
                if onboardingSetupLevelNumber >= 3
                {
                    Text("onboarding.feature.dependency-search")
                    Text("onboarding.feature.complex-dependencies")
                    Text("onboarding.feature.package-purging")
                }
                
                // Advanced
                if onboardingSetupLevelNumber >= 4
                {
                    
                }
            }
        } label: {
            Text("onboarding.details.section.package-features")
        }
    }
}
