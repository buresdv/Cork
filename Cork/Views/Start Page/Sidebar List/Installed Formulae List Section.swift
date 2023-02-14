//
//  InstalledFormulaeListSection.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 12/02/2023.
//

import Foundation
import SwiftUI

struct InstalledFormulaeListSection: View {
    @ObservedObject var brewData: BrewDataStorage
    @ObservedObject var selectedPackageInfo: SelectedPackageInfo
    
    init(_ brewDataStorage: BrewDataStorage, _ selectedPackageInfo: SelectedPackageInfo) {
        self.brewData = brewDataStorage
        self.selectedPackageInfo = selectedPackageInfo
    }
    
    var body: some View {
        Section("Installed Formulae")
        {
            if !brewData.installedFormulae.isEmpty
            {
                ForEach(brewData.installedFormulae)
                { package in
                    NavigationLink
                    {
                        PackageDetailView(
                            package: package,
                            isCask: false,
                            brewData: brewData,
                            packageInfo: selectedPackageInfo
                        )
                    } label: {
                        PackageListItem(packageItem: package)
                    }
                    .contextMenu
                    {
                        Button
                        {
                            Task
                            {
                                await uninstallSelectedPackages(
                                    packages: [package.name],
                                    isCask: false,
                                    brewData: brewData
                                )
                            }
                        } label: {
                            Text("Uninstall Formula")
                        }
                    }
                }
            }
            else
            {
                ProgressView()
            }
        }
        .collapsible(true)
    }
}
