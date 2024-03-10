//
//  Onboarding.swift
//  Cork
//
//  Created by David Bureš on 21.10.2023.
//

import SwiftUI

struct OnboardingView: View
{
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("showRealTimeTerminalOutputOfOperations") var showRealTimeTerminalOutputOfOperations: Bool = false
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false
    
    @AppStorage("displayAdvancedDependencies") var displayAdvancedDependencies: Bool = false
    
    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full
    @AppStorage("showDescriptionsInSearchResults") var showDescriptionsInSearchResults: Bool = false
    
    @AppStorage("showSearchFieldForDependenciesInPackageDetails") var showSearchFieldForDependenciesInPackageDetails: Bool = false
    
    @AppStorage("showInMenuBar") var showInMenuBar = false

    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("outdatedPackageNotificationType") var outdatedPackageNotificationType: OutdatedPackageNotificationType = .badge
    
    @AppStorage("notifyAboutPackageUpgradeResults") var notifyAboutPackageUpgradeResults: Bool = false
    @AppStorage("notifyAboutPackageInstallationResults") var notifyAboutPackageInstallationResults: Bool = false
    
    @AppStorage("showCompatibilityWarning") var showCompatibilityWarning: Bool = true
    
    @AppStorage("enableDiscoverability") var enableDiscoverability: Bool = false
    
    @AppStorage("enableRevealInFinder") var enableRevealInFinder: Bool = false
    
    @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true
    
    @State var onboardingSetupLevel: SetupLevels = .medium

    /// Level numbers:
    /// - 0: Basic
    /// - 1: Slightly basic
    /// - 2: Balanced
    /// - 3: Slightly advanced
    /// - 4: Advanced
    @State var onboardingSetupLevelNumber: Float = 2

    @State private var areDetailsExpanded: Bool = false

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
            })

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
                }
                
                if onboardingSetupLevelNumber >= 2
                {
                    enableDiscoverability = true
                    caveatDisplayOptions = .full
                    areNotificationsEnabled = true
                    outdatedPackageNotificationType = .both
                    
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
                    
                    enableRevealInFinder = true
                }
                
                if onboardingSetupLevelNumber >= 4
                {
                    showRealTimeTerminalOutputOfOperations = true
                }
                
                AppConstants.logger.info("Onboarding finished")
                
                dismiss()
            } label: {
                Text("action.done")
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(LargeButtonStyle())

        })
        .fixedSize()
        .padding()
        .animation(.none, value: areDetailsExpanded)
    }
}
