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
import FactoryKit
import CorkModels

struct OnboardingView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @InjectedObservable(\.appState) var appState: AppState
    
    @Default(.hasFinishedOnboarding) var hasFinishedOnboarding: Bool

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
            //case corkPermissions
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
            VStack(alignment: .center, spacing: 10)
            {
                headerIcon
                    .animation(.easeIn, value: headerIconSize)
                
                onboardingSheetContent
                .toolbar
                {
                    ToolbarItem(placement: .automatic)
                    {
                        Button
                        {
                            hasFinishedOnboarding = true
                        } label: {
                            Text("action.cancel")
                        }
                    }
                }
            }
            .padding()
            .animation(.easeIn, value: onboardingNavigationManager.openedScreen)
        }
        .environment(onboardingNavigationManager)
    }
    
    @ViewBuilder
    private var onboardingSheetContent: some View
    {
        switch onboardingNavigationManager.openedScreen
        {
        case .corkIntroduction:
            Onboarding_InitialView()
                .transition(.move(edge: .top).combined(with: .blurReplace))
        case .corkFeatures:
            Onboarding_FeaturesView(
                onboardingSetupLevelNumber: $onboardingSetupLevelNumber,
                onboardingSetupLevel: $onboardingSetupLevel
            )
            .transition(.move(edge: .bottom).combined(with: .blurReplace))
        // case .corkPermissions:
        //    PermissionsFixSheetContent()
        }
    }
    
    var headerIconSize: CGFloat {
        if case .corkIntroduction = onboardingNavigationManager.openedScreen
        {
            return 100
        }
        else {
            return 50
        }
    }
    
    @ViewBuilder
    private var headerIcon: some View
    {
        Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
            .resizable()
            .frame(width: headerIconSize, height: headerIconSize, alignment: .top)
    }
}
