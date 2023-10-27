//
//  Discoverability Category.swift
//  Cork
//
//  Created by David Bureš on 25.10.2023.
//

import SwiftUI

struct OnboardingDiscoverabilityCategory: View
{
    let onboardingSetupLevelNumber: Float

    var body: some View
    {
        LabeledContent
        {
            VStack(alignment: .trailing, spacing: 3)
            {
                if onboardingSetupLevelNumber <= 1
                {
                    Text("state.disabled")
                }
                else
                {
                    // Basic
                    if onboardingSetupLevelNumber >= 0
                    {}

                    // Slightly basic
                    if onboardingSetupLevelNumber >= 1
                    {}

                    // Balanced
                    if onboardingSetupLevelNumber >= 2
                    {
                        Text("onboarding.feature.discoverability")
                    }

                    // Slightly advanced
                    if onboardingSetupLevelNumber >= 3
                    {}

                    // Advanced
                    if onboardingSetupLevelNumber >= 4
                    {}
                }
            }
        } label: {
            Text("onboarding.details.section.discoverability")
        }
    }
}
