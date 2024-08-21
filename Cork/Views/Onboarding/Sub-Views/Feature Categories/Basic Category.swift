//
//  Basic Category.swift
//  Cork
//
//  Created by David Bureš on 25.10.2023.
//

import SwiftUI

struct OnboardingBasicCategory: View
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
                    Text("onboarding.feature.maintenanace")
                    Text("onboarding.feature.searching")
                }

                // Slightly basic
                if onboardingSetupLevelNumber >= 1 
                {}

                // Below "balanced"
                if onboardingSetupLevelNumber <= 1
                {
                    Text("onboarding.feature.show-only-intentionally-installed-packages")
                }

                // Balanced
                if onboardingSetupLevelNumber >= 2
                {
                    Text("onboarding.feature.show-all-packages")
                }

                // Slightly advanced
                if onboardingSetupLevelNumber >= 3
                {
                    Text("onboarding.feature.revealing-packages-in-finder")
                }

                // Advanced
                if onboardingSetupLevelNumber >= 4 {}
            }
        } label: {
            Text("onboarding.details.section.basic")
        }
    }
}
