//
//  General Pane.swift
//  Cork
//
//  Created by David Bureš on 15.02.2023.
//

import SwiftUI

struct GeneralPane: View
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .none

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                Picker(selection: $sortPackagesBy)
                {
                    Text("Do Not Sort")
                        .tag(PackageSortingOptions.none)
                    Text("Alphabetically")
                        .tag(PackageSortingOptions.alphabetically)
                    Text("By Installation Date")
                        .tag(PackageSortingOptions.byInstallDate)
                    Text("By Size")
                        .tag(PackageSortingOptions.bySize)
                } label: {
                    Text("Sort packages:")
                }
            }
        }
    }
}
