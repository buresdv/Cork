//
//  Onboarding - Features.swift
//  Cork
//
//  Created by David Bureš - P on 19.09.2026.
//

import SwiftUI
import Defaults
import CorkShared
import CorkNotifications

struct Onboarding_FeaturesView: View
{
    @Environment(OnboardingView.OnboardingNavigationManager.self) var onboardingNavigationManager
    
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @Default(.showRealTimeTerminalOutputOfOperations) var showRealTimeTerminalOutputOfOperations: Bool
    @Default(.allowMoreCompleteUninstallations) var allowMoreCompleteUninstallations: Bool

    @Default(.displayAdvancedDependencies) var displayAdvancedDependencies: Bool

    @Default(.caveatDisplayOptions) var caveatDisplayOptions: PackageCaveatDisplay
    @Default(.showDescriptionsInSearchResults) var showDescriptionsInSearchResults: Bool

    @Default(.showSearchFieldForDependenciesInPackageDetails) var showSearchFieldForDependenciesInPackageDetails: Bool
    
    @Default(.showInMenuBar) var showInMenuBar: Bool

    @Default(.areNotificationsEnabled) var areNotificationsEnabled: Bool
    @Default(.outdatedPackageNotificationType) var outdatedPackageNotificationType: OutdatedPackageNotificationType

    @Default(.notifyAboutPackageUpgradeResults) var notifyAboutPackageUpgradeResults: Bool
    @Default(.notifyAboutPackageInstallationResults) var notifyAboutPackageInstallationResults: Bool
    
    @Default(.showCompatibilityWarning) var showCompatibilityWarning: Bool

    @Default(.enableDiscoverability) var enableDiscoverability: Bool

    @Default(.enableRevealInFinder) var enableRevealInFinder: Bool

    @Default(.displayOnlyIntentionallyInstalledPackagesByDefault) var displayOnlyIntentionallyInstalledPackagesByDefault: Bool

    @Default(.outdatedPackageInfoDisplayAmount) var outdatedPackageInfoDisplayAmount: OutdatedPackageInfoAmount
    @Default(.showOldVersionsInOutdatedPackageList) var showOldVersionsInOutdatedPackageList: Bool
    
    @State private var areDetailsExpanded: Bool = false
    
    @Binding var onboardingSetupLevelNumber: Float
    @Binding var onboardingSetupLevel: SetupLevels

    var body: some View
    {
        VStack(alignment: .center, spacing: 20, content: {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 100, height: 100)

            if !areDetailsExpanded
            {
                VStack(alignment: .center, spacing: 5, content: {
                    Text("onboarding.title")
                        .font(.title)

                    Text("onboarding.subtitle")
                })
            }

            VStack(alignment: .leading, spacing: 10, content: {
                OnboardingDefaultsSlider(setupLevel: $onboardingSetupLevel, sliderValue: $onboardingSetupLevelNumber)

                DisclosureGroup(
                    isExpanded: $areDetailsExpanded,
                    content: {
                        if onboardingSetupLevelNumber < 4
                        {
                            Form
                            {
                                OnboardingBasicCategory(onboardingSetupLevelNumber: onboardingSetupLevelNumber)

                                OnboardingDiscoverabilityCategory(onboardingSetupLevelNumber: onboardingSetupLevelNumber)

                                OnboardingPackageFeaturesCategory(onboardingSetupLevelNumber: onboardingSetupLevelNumber)

                                OnboardingTapFeaturesCategory(onboardingSetupLevelNumber: onboardingSetupLevelNumber)

                                OnboardingExtrasCategory(onboardingSetupLevelNumber: onboardingSetupLevelNumber)
                            }
                            .formStyle(.grouped)
                        }
                        else
                        {
                            Text("onboarding.all-features-enabled")
                        }
                    },
                    label: {
                        Text(areDetailsExpanded ? "add-package.install.hide-details" : "add-package.install.show-details")
                    }
                )
                .betterDisclosureGroupStyle()
            })
        })
        .navigationTitle("onboarding.title")
        .animation(.none, value: areDetailsExpanded)
        .toolbar {
            ToolbarItem(placement: .primaryAction)
            {
                Button
                {
                    /// First, purge all the current defaults if there are any
                    if let bundleID = Bundle.main.bundleIdentifier
                    {
                        UserDefaults.standard.removePersistentDomain(forName: bundleID)
                    }

                    /// Now, do all the setup
                    if onboardingSetupLevelNumber >= 1
                    {
                        showDescriptionsInSearchResults = true
                        showCompatibilityWarning = true
                        outdatedPackageInfoDisplayAmount = .none
                    }

                    if onboardingSetupLevelNumber >= 2
                    {
                        enableDiscoverability = true
                        caveatDisplayOptions = .full
                        areNotificationsEnabled = true
                        outdatedPackageNotificationType = .both

                        outdatedPackageInfoDisplayAmount = .versionOnly
                        showOldVersionsInOutdatedPackageList = true

                        displayOnlyIntentionallyInstalledPackagesByDefault = false
                    }

                    if onboardingSetupLevelNumber >= 3
                    {
                        showSearchFieldForDependenciesInPackageDetails = true
                        displayAdvancedDependencies = true
                        allowMoreCompleteUninstallations = true
                        showInMenuBar = true

                        notifyAboutPackageUpgradeResults = true
                        notifyAboutPackageInstallationResults = true

                        outdatedPackageInfoDisplayAmount = .all

                        enableRevealInFinder = true
                    }

                    if onboardingSetupLevelNumber >= 4
                    {
                        showRealTimeTerminalOutputOfOperations = true
                    }

                    AppConstants.shared.logger.info("Onboarding finished")

                    onboardingNavigationManager.navigate(to: .corkPermissions)
                } label: {
                    Text("action.continue")
                }
                .keyboardShortcut(.defaultAction)
                //.controlSize(.large)
            }
        }
    }
}
