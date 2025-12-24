//
//  Adoptable Packages Box.swift
//  Cork
//
//  Created by David Bureš - P on 04.10.2025.
//

import CorkShared
import Defaults
import SwiftUI
import ButtonKit
import SwiftData
import CorkModels

struct AdoptablePackagesSection: View
{
    @Default(.allowMassPackageAdoption) var allowMassPackageAdoption: Bool
    @Default(.enableExtraAnimations) var enableExtraAnimations: Bool
    
    @Default(.hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable) var hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable: Bool

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @State private var isShowingAdoptionWarning: Bool = false
    
    @Query private var excludedApps: [ExcludedAdoptableApp]
    
    @State private var isAdoptablePackagesDisclosureGroupOpened: Bool = false
    @State private var isExcludedAdoptablePackagesDisclosureGroupOpened: Bool = false

    enum SectionDisplayType
    {
        case full, minimized
    }
    
    var sectionDisplayType: SectionDisplayType
    {
        if brewPackagesTracker.adoptableAppsNonExcluded.isEmpty
        {
            return .full
        }
        else
        {
            return .minimized
        }
    }
    
    var displayNumberOfExcludedPackages: Bool
    {
        if !brewPackagesTracker.excludedAdoptableApps.isEmpty && !brewPackagesTracker.adoptableAppsNonExcluded.isEmpty
        {
            return true
        } else {
            return false
        }
        
    }
    
    enum AdoptablePackagesHeadlineState
    {
        case showsAdoptablePackages
        case showsExcludedPackagesOnly
    }
    
    var adoptablePackagesHeadlineState: AdoptablePackagesHeadlineState
    {
        if !brewPackagesTracker.adoptableAppsNonExcluded.isEmpty
        {
            return .showsAdoptablePackages
        }
        else if !brewPackagesTracker.excludedAdoptableApps.isEmpty
        {
            return .showsExcludedPackagesOnly
        }
        else
        {
            return .showsExcludedPackagesOnly
        }
    }
    
    var body: some View
    {
        if !brewPackagesTracker.adoptableApps.isEmpty
        {
            if allowMassPackageAdoption
            {
                if !(hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable && brewPackagesTracker.adoptableAppsNonExcluded.isEmpty)
                {
                    adoptablePackagesSectionContent
                }
                else
                {
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    var adoptablePackagesSectionContent: some View
    {
        Section
        {
            GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.shippingbox.2.badge.arrow.down")
            {
                VStack(alignment: .leading)
                {
                    HStack(alignment: .firstTextBaseline)
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Group
                            {
                                switch adoptablePackagesHeadlineState
                                {
                                case .showsAdoptablePackages:
                                    Text("start-page.adoptable-packages.available.\(brewPackagesTracker.adoptableAppsNonExcluded.count)")
                                case .showsExcludedPackagesOnly:
                                    Text("start-page.adoptable-packages.only-\(excludedApps.count)-excluded-available")
                                }
                            }
                            .font(.headline)
                            
                            if displayNumberOfExcludedPackages
                            {
                                Text("start-page.adoptable-packages.excluded.\(excludedApps.count)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .transition(.asymmetric(
                                        insertion: .push(from: .top).combined(with: .opacity),
                                        removal: .push(from: .bottom).combined(with: .opacity))
                                    )
                            }
                        }
                        .modify
                        { viewProxy in
                            if enableExtraAnimations
                            {
                                viewProxy
                                    .animation(.bouncy, value: brewPackagesTracker.adoptableAppsNonExcluded.count)
                                    .animation(.bouncy, value: excludedApps.count)
                                    .contentTransition(.numericText())
                            }
                            else
                            {
                                viewProxy
                            }
                        }
                        
                        Spacer()
                        
                        HStack
                        {
                            startAdoptionProcessButton
                            
                            if adoptablePackagesHeadlineState == .showsExcludedPackagesOnly
                            {
                                hideAdoptablePackagesSectionIfThereAreOnlyIgnoredAppsButton
                                    .transition(.asymmetric(
                                        insertion: .push(from: .trailing),
                                        removal: .push(from: .leading)
                                    ))
                            }
                        }
                    }
                    .animation(.smooth, value: adoptablePackagesHeadlineState)
                    
                    if !brewPackagesTracker.adoptableAppsNonExcluded.isEmpty
                    {
                        DisclosureGroup(isExpanded: $isAdoptablePackagesDisclosureGroupOpened.animation()) {
                            AdoptablePackagesList()
                        } label: {
                            Text("adoptable-packages.label")
                        }
                    }
                    
                    if !brewPackagesTracker.excludedAdoptableApps.isEmpty
                    {
                        DisclosureGroup(isExpanded: $isExcludedAdoptablePackagesDisclosureGroupOpened.animation()) {
                            excludedAdoptablePackagesList
                        } label: {
                            Text("adoptable-packages.excluded-label")
                        }
                    }
                    
                    #if DEBUG
                    debug_listPackagesThatWouldGetAdopted
                    #endif
                }
                .animation(.smooth, value: excludedApps)
                .transition(.push(from: .top).combined(with: .blurReplace))
            }
            .animation(.bouncy, value: brewPackagesTracker.adoptableApps.isEmpty)
            .confirmationDialog("package-adoption.confirmation.title.\(brewPackagesTracker.adoptableAppsSelectedToBeAdopted.count)", isPresented: $isShowingAdoptionWarning)
            {
                Button
                {
                    isShowingAdoptionWarning = false

                    appState.showSheet(ofType:
                            .massAppAdoption(
                                appsToAdopt: brewPackagesTracker.adoptableAppsSelectedToBeAdopted
                            )
                    )
                } label: {
                    Text("action.adopt-packages.longer")
                }
                .keyboardShortcut(.defaultAction)

                Button(role: .cancel)
                {
                    isShowingAdoptionWarning = false
                } label: {
                    Text("action.cancel")
                }

                Button(role: .cancel)
                {
                    isShowingAdoptionWarning = false
                } label: {
                    Text("action.cancel-and-disable-mass-adoption")
                }

            } message: {
                Text("package-adoption.confirmation.message")
                
                List
                {
                    Text("package-adoption.confirmation.message")
                    Text("package-adoption.confirmation.message")
                }
            }
            .dialogSeverity(.standard)
            .confirmationDialog("hide-adoptable-packages-section-if-only-excluded-apps-available.confirmation.title", isPresented: $isShowingAdoptablePackagesSectionHidingWarningIfThereAreOnlyExcludedAdoptablePackagesAvailable)
            {
                if #available(macOS 26, *)
                {
                    Button(role: .confirm)
                    {
                        hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable = true
                    } label: {
                        Text("action.hide-adoptable-packages-section-if-only-excluded-apps-available.confirm")
                    }
                    .keyboardShortcut(.defaultAction)
                }
                else
                {
                    Button
                    {
                        hideAdoptablePackagesSectionIfThereAreOnlyExcludedAppsAvailable = true
                    } label: {
                        Text("action.hide-adoptable-packages-section-if-only-excluded-apps-available.confirm")
                    }
                    .keyboardShortcut(.defaultAction)
                }
                
                Button(role: .cancel)
                {
                    isShowingAdoptablePackagesSectionHidingWarningIfThereAreOnlyExcludedAdoptablePackagesAvailable = false
                } label: {
                    Text("action.cancel")
                }
                .keyboardShortcut(.cancelAction)

            } message: {
                Text("hide-adoptable-packages-section-if-only-excluded-apps-available.confirmation.message")
            }

        }
        .animation(.smooth, value: brewPackagesTracker.adoptableAppsNonExcluded)
        .animation(.smooth, value: brewPackagesTracker.excludedAdoptableApps)
    }

    @ViewBuilder
    var startAdoptionProcessButton: some View
    {
        Button
        {
            isShowingAdoptionWarning = true

            AppConstants.shared.logger.info("Will adopt \(brewPackagesTracker.adoptableAppsSelectedToBeAdopted.count, privacy: .public) apps")
        } label: {
            if brewPackagesTracker.hasSelectedOnlySomeAppsToAdopt
            {
                Text("action.adopt-some-packages.\(brewPackagesTracker.adoptableAppsSelectedToBeAdopted.count)")
            }
            else
            {
                Text("action.adopt-packages")
            }
        }
        .disabled(brewPackagesTracker.adoptableAppsSelectedToBeAdopted.isEmpty)
    }
    
    @State private var isShowingAdoptablePackagesSectionHidingWarningIfThereAreOnlyExcludedAdoptablePackagesAvailable: Bool = false
    
    @ViewBuilder
    var hideAdoptablePackagesSectionIfThereAreOnlyIgnoredAppsButton: some View
    {
        Button {
            isShowingAdoptablePackagesSectionHidingWarningIfThereAreOnlyExcludedAdoptablePackagesAvailable = true
        } label: {
            Label("action.hide-adoptable-packages-section-if-only-excluded-apps-available", systemImage: "eye.slash")
        }
        .labelStyle(.titleOnly)
    }
    
    @State private var numberOfMaxShownIgnoredAdoptableApps: Int = 5
        
    @ViewBuilder
    var excludedAdoptablePackagesList: some View
    {
        List
        {
            Section
            {
                ForEach(brewPackagesTracker.excludedAdoptableApps.prefix(numberOfMaxShownIgnoredAdoptableApps))
                { ignoredApp in
                    AdoptablePackageListItem(adoptableCask: ignoredApp, exclusionButtonType: .includeOnly)
                        .saturation(0.3)
                }
            } footer: {
                HStack(alignment: .center)
                {
                    Button
                    {
                        withAnimation
                        {
                            numberOfMaxShownIgnoredAdoptableApps += 10
                        }
                    } label: {
                        Label("action.show-more", systemImage: "chevron.down")
                    }
                    .buttonStyle(.accessoryBar)
                    .disabled(numberOfMaxShownIgnoredAdoptableApps >= brewPackagesTracker.excludedAdoptableApps.count)

                    Spacer()

                    Button
                    {
                        withAnimation
                        {
                            numberOfMaxShownIgnoredAdoptableApps -= 10
                        }
                    } label: {
                        Label("action.show-less", systemImage: "chevron.up")
                    }
                    .buttonStyle(.accessoryBar)
                    .disabled(numberOfMaxShownIgnoredAdoptableApps < 7)
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .animation(.smooth, value: excludedApps)
        .transition(.push(from: .top))
    }
    
    #if DEBUG
    // MARK: - Debug stuff
    @ViewBuilder
    var debug_listPackagesThatWouldGetAdopted: some View
    {
        Button
        {
            let namesOfAdoptedPackages: [String] = brewPackagesTracker.adoptableAppsSelectedToBeAdopted.map{ $0.selectedAdoptionCandidateCaskName! }
            
            AppConstants.shared.logger.debug("\(namesOfAdoptedPackages.count), \(namesOfAdoptedPackages.formatted(.list(type: .and)))")
        } label: {
            Text("DEBUG: Log packages to be adopted")
        }
    }
    #endif
}
