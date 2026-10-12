//
//  Onboarding.swift
//  Cork
//
//  Created by David Bureš on 21.10.2023.
//

import CorkNotifications
import CorkShared
import Defaults
import SwiftUI

struct OnboardingView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var onboardingSetupLevel: SetupLevels = .medium

    /// Level numbers:
    /// - 0: Basic
    /// - 1: Slightly basic
    /// - 2: Balanced
    /// - 3: Slightly advanced
    /// - 4: Advanced
    @State var onboardingSetupLevelNumber: Float = 2

    @Observable
    class OnboardingNavigationManager
    {
        enum OnboardingScreen: Hashable
        {
            case corkIntroduction
            case corkFeatures
            case corkPermissions
            case corkLicense
        }

        var openedScreen: OnboardingScreen = .corkIntroduction
        
        func navigate(to newScreen: OnboardingScreen)
        {
            self.openedScreen = newScreen
        }
    }

    @State private var onboardingNavigationManager: OnboardingNavigationManager = .init()

    var body: some View
    {
        NavigationStack
        {
            Group
            {
                switch onboardingNavigationManager.openedScreen
                {
                case .corkIntroduction:
                    Onboarding_InitialView()
                case .corkFeatures:
                    Onboarding_FeaturesView(
                        onboardingSetupLevelNumber: $onboardingSetupLevelNumber,
                        onboardingSetupLevel: $onboardingSetupLevel
                    )
                case .corkPermissions:
                    PermissionsFixSheetContent()
                case .corkLicense:
                    LicensingView()
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction)
                {
                    DismissSheetButton()
                }
            }
            
        }
        .fixedSize()
        .environment(onboardingNavigationManager)
    }
}
