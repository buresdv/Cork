//
//  Adoptable Packages Box.swift
//  Cork
//
//  Created by David Bureš - P on 04.10.2025.
//

import CorkShared
import Defaults
import SwiftUI

struct AdoptablePackagesBox: View
{
    @Default(.allowMassPackageAdoption) var allowMassPackageAdoption: Bool

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @State private var isShowingAdoptionWarning: Bool = false

    var body: some View
    {
        if !brewPackagesTracker.adoptableApps.isEmpty
        {
            GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.shippingbox.2.badge.arrow.down")
            {
                HStack(alignment: .firstTextBaseline)
                {
                    VStack(alignment: .leading)
                    {
                        Text("start-page.adoptable-packages.available.\(brewPackagesTracker.adoptableApps.count)")
                            .font(.headline)

                        DisclosureGroup("adoptable-packages.label")
                        {
                            adoptablePackagesList
                        }
                    }

                    Button
                    {
                        isShowingAdoptionWarning = true

                        AppConstants.shared.logger.info("Will adopt \(brewPackagesTracker.adoptableApps.count, privacy: .public) apps")
                    } label: {
                        Text("action.adopt-packages")
                    }
                }
            }
            .animation(.bouncy, value: brewPackagesTracker.adoptableApps.isEmpty)
            .confirmationDialog("package-adoption.confirmation.title.\(brewPackagesTracker.adoptableApps.count)", isPresented: $isShowingAdoptionWarning)
            {
                Button
                {
                    isShowingAdoptionWarning = false
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
        } label: {
            Text("start-page.updated.action.deselect-all")
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var selectAllButton: some View
    {
        Button
        {
            AppConstants.shared.logger.debug("Will select all adoptable casks")
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
