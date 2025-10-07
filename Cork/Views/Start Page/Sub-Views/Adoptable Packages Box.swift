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
        if !brewPackagesTracker.adoptableCasks.isEmpty
        {
            GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.shippingbox.2.badge.arrow.down")
            {
                HStack(alignment: .firstTextBaseline)
                {
                    VStack(alignment: .leading)
                    {
                        Text("start-page.adoptable-packages.available.\(brewPackagesTracker.adoptableCasks.count)")
                            .font(.headline)

                        DisclosureGroup("adoptable-packages.label")
                        {
                            adoptablePackagesList
                        }
                    }

                    Button
                    {
                        isShowingAdoptionWarning = true

                        AppConstants.shared.logger.info("Will adopt \(brewPackagesTracker.adoptableCasks.count, privacy: .public) apps")
                    } label: {
                        Text("action.adopt-packages")
                    }
                }
            }
            .animation(.bouncy, value: brewPackagesTracker.adoptableCasks.isEmpty)
            .confirmationDialog("package-adoption.confirmation.title.\(brewPackagesTracker.adoptableCasks.count)", isPresented: $isShowingAdoptionWarning)
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

    @ViewBuilder
    var adoptablePackagesList: some View
    {
        List
        {
            Section
            {
                ForEach(brewPackagesTracker.adoptableCasks.sorted(by: { $0.caskName < $1.caskName }))
                { adoptableCask in
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            adoptableCask.isMarkedForAdoption
                        }, set: { toggleState in
                            if let index = brewPackagesTracker.adoptableCasks.firstIndex(where: { $0.id == adoptableCask.id }) {
                                brewPackagesTracker.adoptableCasks[index].changeMarkedState()  // This WOULD trigger onChange
                            }
                        }
                    )) {
                        AdoptablePackageListItem(adoptableCask: adoptableCask)
                    }
                }
            } header: {
                HStack(alignment: .center, spacing: 10)
                {
                    deselectAllButton

                    selectAllButton
                }
            }
            .onChange(of: brewPackagesTracker.adoptableCasks) { oldValue, newValue in
                print("CHANGE!")
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
        .buttonStyle(.plain)
    }
}

struct AdoptablePackageListItem: View
{
    let adoptableCask: BrewPackagesTracker.AdoptableCaskComparable

    let adoptableCaskAppLocation: URL

    let adoptableCaskApp: Application?

    init(adoptableCask: BrewPackagesTracker.AdoptableCaskComparable)
    {
        self.adoptableCask = adoptableCask
        self.adoptableCaskAppLocation = URL.applicationDirectory.appendingPathComponent(adoptableCask.caskExecutable, conformingTo: .application)
        self.adoptableCaskApp = try? .init(from: self.adoptableCaskAppLocation)
    }

    var body: some View
    {
        HStack(alignment: .center, spacing: 5)
        {
            if let adoptableCaskApp
            {
                if let adoptableCaskIcon = adoptableCaskApp.iconImage
                {
                    adoptableCaskIcon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 5)
            {
                Text(adoptableCask.caskExecutable)

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
                adoptableCaskAppLocation.revealInFinder(.openParentDirectoryAndHighlightTarget)
            } label: {
                Label("action.reveal-\(adoptableCask.caskExecutable)-in-finder", systemImage: "finder")
            }
        }
    }
}
