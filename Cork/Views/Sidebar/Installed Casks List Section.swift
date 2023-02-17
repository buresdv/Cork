//
//  Installed Casks List Section.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 17/02/2023.
//

import Foundation
import SwiftUI

struct InstalledCasksListSection: View {
    var brewData: BrewDataStorage
    var selectedPackageInfo: SelectedPackageInfo
    var appState: AppState
    
    var body: some View {
        ForEach(brewData.installedCasks)
        { cask in
            NavigationLink {
                PackageDetailView(package: cask, packageInfo: selectedPackageInfo)
            } label: {
                PackageListItem(packageItem: cask)
            }
            .contextMenu
            {
                Button {
                    Task
                    {
                        await uninstallSelectedPackage(package: cask, brewData: brewData, appState: appState)
                    }
                } label: {
                    Text("Uninstall Cask")
                }
                
            }
            
        }
    }
}
