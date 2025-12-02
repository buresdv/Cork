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

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @State private var isShowingAdoptionWarning: Bool = false
    
    @Query private var excludedApps: [ExcludedAdoptableApp]
    
    @State private var isAdoptablePackagesDisclosureGroupOpened: Bool = false
    @State private var isExcludedAdoptablePackagesDisclosureGroupOpened: Bool = false

    var body: some View
    {
        if !brewPackagesTracker.adoptableApps.isEmpty
        {
            if allowMassPackageAdoption
            {
                Section
                {
                    GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.shippingbox.2.badge.arrow.down")
                    {
                        VStack(alignment: .leading)
                        {
                            HStack(alignment: .firstTextBaseline)
                            {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("start-page.adoptable-packages.available.\(brewPackagesTracker.adoptableAppsNonExcluded.count)")
                                        .font(.headline)
                                    
                                    if !brewPackagesTracker.excludedAdoptableApps.isEmpty
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

                            DisclosureGroup(isExpanded: $isAdoptablePackagesDisclosureGroupOpened.animation()) {
                                adoptablePackagesList
                            } label: {
                                Text("adoptable-packages.label")
                            }
                            .animation(.smooth, value: excludedApps)
                            
                            if !brewPackagesTracker.excludedAdoptableApps.isEmpty
                            {
                                DisclosureGroup(isExpanded: $isExcludedAdoptablePackagesDisclosureGroupOpened.animation()) {
                                    excludedAdoptablePackagesList
                                } label: {
                                    Text("adoptable-packages.excluded-label")
                                }
                                .animation(.smooth, value: excludedApps)
                                
                            }
                        }
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
                }
            }
        }
    }

    @State private var numberOfMaxShownAdoptableApps: Int = 5
    
    @State private var numberOfMaxShownIgnoredAdoptableApps: Int = 5

    @ViewBuilder
    var adoptablePackagesList: some View
    {
        List
        {
            Section
            {
                ForEach(brewPackagesTracker.adoptableAppsNonExcluded.prefix(numberOfMaxShownAdoptableApps))
                { adoptableCask in
                    HStack(alignment: .center)
                    {
                        Toggle(isOn: Binding<Bool>(
                            get: {
                                adoptableCask.isMarkedForAdoption
                            }, set: { _ in
                                if let index = brewPackagesTracker.adoptableApps.firstIndex(where: { $0.id == adoptableCask.id })
                                {
                                    brewPackagesTracker.adoptableApps[index].changeMarkedState()
                                }
                            }
                        ))
                        {
                            EmptyView()
                        }
                        .labelsHidden()

                        AdoptablePackageListItem(adoptableCask: adoptableCask, exclusionButtonType: .excludeOnly)
                            .onTapGesture
                            {
                                if let index = brewPackagesTracker.adoptableApps.firstIndex(where: { $0.id == adoptableCask.id })
                                {
                                    brewPackagesTracker.adoptableApps[index].changeMarkedState()
                                }
                            }
                    }
                }
            } header: {
                HStack(alignment: .center, spacing: 10)
                {
                    deselectAllButton

                    selectAllButton
                }
            } footer: {
                HStack(alignment: .center)
                {
                    Button
                    {
                        withAnimation
                        {
                            numberOfMaxShownAdoptableApps += 10
                        }
                    } label: {
                        Label("action.show-more", systemImage: "chevron.down")
                    }
                    .buttonStyle(.accessoryBar)
                    .disabled(numberOfMaxShownAdoptableApps >= brewPackagesTracker.adoptableAppsNonExcluded.count)

                    Spacer()

                    Button
                    {
                        withAnimation
                        {
                            numberOfMaxShownAdoptableApps -= 10
                        }
                    } label: {
                        Label("action.show-less", systemImage: "chevron.up")
                    }
                    .buttonStyle(.accessoryBar)
                    .disabled(numberOfMaxShownAdoptableApps < 7)
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
    }
    
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
    }

    @ViewBuilder
    var deselectAllButton: some View
    {
        Button
        {
            AppConstants.shared.logger.debug("Will deselect all adoptable casks")

            for (index, _) in brewPackagesTracker.adoptableApps.enumerated()
            {
                brewPackagesTracker.adoptableApps[index].isMarkedForAdoption = false
            }

        } label: {
            Text("start-page.updated.action.deselect-all")
        }
        .buttonStyle(.accessoryBar)
    }

    @ViewBuilder
    var selectAllButton: some View
    {
        Button
        {
            AppConstants.shared.logger.debug("Will select all adoptable casks")

            for (index, _) in brewPackagesTracker.adoptableApps.enumerated()
            {
                brewPackagesTracker.adoptableApps[index].isMarkedForAdoption = true
            }

        } label: {
            Text("start-page.updated.action.select-all")
        }
        .buttonStyle(.accessoryBar)
    }
}

struct AdoptablePackageListItem: View
{
    enum ExclusionButtonType
    {
        case excludeOnly, includeOnly, none
    }
    
    let adoptableCask: BrewPackagesTracker.AdoptableApp
    
    let exclusionButtonType: ExclusionButtonType

    var body: some View
    {
        HStack(alignment: .center, spacing: 5)
        {
            if let app = adoptableCask.app
            {
                AppIconDisplay(
                    displayType: .asIcon(usingApp: app),
                    allowRevealingInFinderFromIcon: false
                )
            }

            VStack(alignment: .leading, spacing: 2)
            {
                HStack(alignment: .firstTextBaseline, spacing: 5)
                {
                    Text(adoptableCask.appExecutable)

                    Text("(\(adoptableCask.caskName))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let caskDescription = adoptableCask.description
                {
                    Text(caskDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contextMenu
        {
            PreviewPackageButtonWithCustomLabel(label: "action.preview-package-app-would-be-adopted-as.\(adoptableCask.caskName)", packageToPreview: .init(name: adoptableCask.caskName, type: .cask, installedIntentionally: true))

            Button
            {
                adoptableCask.fullAppUrl.revealInFinder(.openParentDirectoryAndHighlightTarget)
            } label: {
                Label("action.reveal-\(adoptableCask.appExecutable)-in-finder", systemImage: "finder")
            }
            
            Divider()
            
            switch exclusionButtonType {
            case .excludeOnly:
                ignoreAdoptableAppButton(appToIgnore: adoptableCask)
            case .includeOnly:
                includeAdoptableAppButton(appToInclude: adoptableCask)
            case .none:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    func ignoreAdoptableAppButton(appToIgnore: BrewPackagesTracker.AdoptableApp) -> some View
    {
        AsyncButton
        {
            AppConstants.shared.logger.info("Adding app \(appToIgnore.appExecutable) to the excluded apps")
            
            await appToIgnore.excludeSelf()
        } label: {
            Label("action.package-adoption.ignore.\(appToIgnore.appExecutable)", systemImage: "xmark.circle")
        }
    }
    
    @ViewBuilder
    func includeAdoptableAppButton(appToInclude: BrewPackagesTracker.AdoptableApp) -> some View
    {
        AsyncButton
        {
            AppConstants.shared.logger.info("Removing app \(appToInclude.appExecutable) from the excluded apps")
            
            await appToInclude.includeSelf()
        } label: {
            Label("action.package-adoption.include.\(appToInclude.appExecutable)", systemImage: "plus.circle")
        }
    }
}
