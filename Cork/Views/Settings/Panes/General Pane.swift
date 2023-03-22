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

    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full
    @AppStorage("showDescriptionsInSearchResults") var showDescriptionsInSearchResults: Bool = false
    
    @AppStorage("showSearchFieldForDependenciesInPackageDetails") var showSearchFieldForDependenciesInPackageDetails: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                Picker(selection: $sortPackagesBy)
                {
                    Text("settings.general.sort-packages.alphabetically")
                        .tag(PackageSortingOptions.alphabetically)
                    Text("settings.general.sort-packages.install-date")
                        .tag(PackageSortingOptions.byInstallDate)
                    Text("settings.general.sort-packages.size")
                        .tag(PackageSortingOptions.bySize)

                    Divider()

                    Text("settings.general.sort-packages.none")
                        .tag(PackageSortingOptions.none)
                } label: {
                    Text("settings.general.sort-packages")
                }

                if sortPackagesBy == .none
                {
                    Text("settings.general.sort-packages.restart")
                        .font(.caption)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                }

                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $displayAdvancedDependencies)
                        {
                            Text("settings.general.dependencies.toggle")
                        }
                    }
                } label: {
                    Text("settings.general.dependencies")
                }

                Picker(selection: $caveatDisplayOptions)
                {
                    Text("settings.general.package-caveats.full")
                        .tag(PackageCaveatDisplay.full)
                    Text("settings.general.package-caveats.minified")
                        .tag(PackageCaveatDisplay.mini)
                } label: {
                    Text("settings.general.package-caveats")
                }
                .pickerStyle(.radioGroup)
                if caveatDisplayOptions == .mini
                {
                    Text("settings.general.package-caveats.minified.info")
                        .font(.caption)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                }

                LabeledContent
                {
                    Toggle(isOn: $showDescriptionsInSearchResults)
                    {
                        Text("settings.general.search-results.toggle")
                    }
                } label: {
                    Text("settings.general.search-results")
                }

                LabeledContent
                {
                    Toggle(isOn: $showSearchFieldForDependenciesInPackageDetails) {
                        Text("settings.general.package-details.toggle")
                    }
                } label: {
                    Text("settings.general.package-details")
                }
            }
        }
    }
}
