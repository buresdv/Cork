//
//  Installed Cask List Section.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 12/02/2023.
//

import Foundation
import SwiftUI

struct InstalledCaskListSection : View {
    @ObservedObject var brewData: BrewDataStorage
    @ObservedObject var selectedPackageInfo: SelectedPackageInfo
    
    init(_ brewData: BrewDataStorage, _ selectedPackageInfo: SelectedPackageInfo) {
        self.brewData = brewData
        self.selectedPackageInfo = selectedPackageInfo
    }
    
    var body: some View {
        Section("Installed Casks")
        {
            if !brewData.installedCasks.isEmpty
            {
                ForEach(brewData.installedCasks)
                { package in
                    NavigationLink
                    {
                        PackageDetailView(
                            package: package,
                            isCask: true,
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
                                    isCask: true,
                                    brewData: brewData
                                )
                            }
                        } label: {
                            Text("Uninstall Cask")
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
