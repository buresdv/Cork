//
//  Adoptable Packages Box.swift
//  Cork
//
//  Created by David Bureš - P on 04.10.2025.
//

import CorkShared
import Defaults
import SwiftUI

struct AdoptablePackagesSection: View
{
    @Default(.allowMassPackageAdoption) var allowMassPackageAdoption: Bool

    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @State private var isShowingAdoptionWarning: Bool = false

    var body: some View
    {
        if !brewPackagesTracker.adoptableApps.isEmpty
        {
            Section
            {
                GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.shippingbox.2.badge.arrow.down")
                {
                    VStack(alignment: .leading)
                    {
                        HStack(alignment: .firstTextBaseline)
                        {
                            Text("start-page.adoptable-packages.available.\(brewPackagesTracker.adoptableApps.count)")
                                .font(.headline)

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

                        DisclosureGroup("adoptable-packages.label")
                        {
                            adoptablePackagesList
                        }
                    }
                }
                .animation(.bouncy, value: brewPackagesTracker.adoptableApps.isEmpty)
                .confirmationDialog("package-adoption.confirmation.title.\(brewPackagesTracker.adoptableAppsSelectedToBeAdopted.count)", isPresented: $isShowingAdoptionWarning)
                {
                    Button
                    {
                        isShowingAdoptionWarning = false

                        appState.showSheet(ofType: .massAppAdoption(appsToAdopt: brewPackagesTracker.adoptableAppsSelectedToBeAdopted))
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
                }
                .dialogSeverity(.standard)
            }
        }
    }

    @State private var numberOfMaxShownAdoptableApps: Int = 5

    @ViewBuilder
    var adoptablePackagesList: some View
    {
        List
        {
            Section
            {
                ForEach(brewPackagesTracker.adoptableApps.sorted(by: { $0.caskName < $1.caskName }).prefix(numberOfMaxShownAdoptableApps))
                { adoptableCask in
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
                        AdoptablePackageListItem(adoptableCask: adoptableCask)
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
                    .disabled(numberOfMaxShownAdoptableApps >= brewPackagesTracker.adoptableApps.count)

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
    let adoptableCask: BrewPackagesTracker.AdoptableApp

    var body: some View
    {
        HStack(alignment: .center, spacing: 5)
        {
            if let app = adoptableCask.app
            {
                if let adoptableCaskIcon = app.iconImage
                {
                    adoptableCaskIcon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 5)
            {
                Text(adoptableCask.appExecutable)

                Text("(\(adoptableCask.caskName))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
        }
    }
}
