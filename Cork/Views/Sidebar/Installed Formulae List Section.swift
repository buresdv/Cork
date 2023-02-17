//
//  Installed Formulae List Section.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 17/02/2023.
//

import Foundation
import SwiftUI

struct InstalledFormulaeListSection: View {
    var brewData: BrewDataStorage
    var selectedPackageInfo: SelectedPackageInfo
    var appState: AppState
    
    var body: some View {
        ForEach(brewData.installedFormulae)
        { formula in
            NavigationLink
            {
                PackageDetailView(package: formula, packageInfo: selectedPackageInfo)
            } label: {
                PackageListItem(packageItem: formula)
            }
            .contextMenu
            {
                Button {
                    Task{
                        await uninstallSelectedPackage(package: formula, brewData: brewData, appState: appState)
                    }
                } label: {
                    Text("Uninstall Formula")
                }

            }
        }
    }
}
