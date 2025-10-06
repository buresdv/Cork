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
                            List(brewPackagesTracker.adoptableCasks.sorted(by: { $0.caskName < $1.caskName }))
                            { adoptableCask in
                                Text(adoptableCask.caskName)
                                    .contextMenu
                                    {
                                        RevealInFinderButtonWithArbitraryAction
                                        {}
                                    }
                            }
                            .listStyle(.bordered(alternatesRowBackgrounds: true))
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
}
