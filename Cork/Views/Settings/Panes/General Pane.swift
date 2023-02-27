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
    @AppStorage("displayAdvancedDependencies") var displayAdvancedDependencies: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                Picker(selection: $sortPackagesBy)
                {
                    Text("Alphabetically")
                        .tag(PackageSortingOptions.alphabetically)
                    Text("By Installation Date")
                        .tag(PackageSortingOptions.byInstallDate)
                    Text("By Size")
                        .tag(PackageSortingOptions.bySize)
                    
                    Divider()
                    
                    Text("Do Not Sort")
                        .tag(PackageSortingOptions.none)
                } label: {
                    Text("Sort packages:")
                }
                
                if sortPackagesBy == .none
                {
                    Text("􀅴 Restart Cork for this sorting option to take effect")
                        .font(.caption)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                }
                
                LabeledContent {
                    Toggle(isOn: $displayAdvancedDependencies) {
                        Text("Show more info about dependecies")
                    }
                } label: {
                    Text("Interface:")
                }

            }
        }
    }
}
