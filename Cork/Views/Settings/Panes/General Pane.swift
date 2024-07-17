//
//  General Pane.swift
//  Cork
//
//  Created by David Bureš on 15.02.2023.
//

import LaunchAtLogin
import SwiftUI

struct GeneralPane: View
{
    @AppStorage("sortPackagesBy") var sortPackagesBy: PackageSortingOptions = .byInstallDate
    @AppStorage("displayAdvancedDependencies") var displayAdvancedDependencies: Bool = false

    @AppStorage("displayOnlyIntentionallyInstalledPackagesByDefault") var displayOnlyIntentionallyInstalledPackagesByDefault: Bool = true

    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full
    @AppStorage("showDescriptionsInSearchResults") var showDescriptionsInSearchResults: Bool = false

    @AppStorage("outdatedPackageInfoDisplayAmount") var outdatedPackageInfoDisplayAmount: OutdatedPackageInfoAmount = .all

    @AppStorage("enableRevealInFinder") var enableRevealInFinder: Bool = false

    @AppStorage("showSearchFieldForDependenciesInPackageDetails") var showSearchFieldForDependenciesInPackageDetails: Bool = false

    @AppStorage("showInMenuBar") var showInMenuBar = false
    @AppStorage("startWithoutWindow") var startWithoutWindow: Bool = false

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
                } label: {
                    Text("settings.general.sort-packages")
                }

                Picker(selection: $displayOnlyIntentionallyInstalledPackagesByDefault)
                {
                    Text("settings.general.display-only-intentionally-installed-packages.yes")
                        .tag(true)
                    Text("settings.general.display-only-intentionally-installed-packages.no")
                        .tag(false)
                } label: {
                    Text("settings.general.display-only-intentionally-installed-packages")
                }
                .pickerStyle(.radioGroup)

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

                Picker(selection: $outdatedPackageInfoDisplayAmount)
                {
                    ForEach(OutdatedPackageInfoAmount.allCases)
                    { infoAmount in
                        
                        Text(infoAmount.localizedName)
                            .tag(infoAmount)
                        
                    }
                } label: {
                    Text("settings.general.outdated-packages")
                }

                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $showSearchFieldForDependenciesInPackageDetails)
                        {
                            Text("settings.general.package-details.toggle")
                        }

                        Toggle(isOn: $enableRevealInFinder)
                        {
                            Text("settings.general.package-details.reveal-in-finder.toggle")
                        }
                    }
                } label: {
                    Text("settings.general.package-details")
                }

                LabeledContent
                {
                    VStack(alignment: .leading, spacing: 4)
                    {
                        Toggle(isOn: $showInMenuBar)
                        {
                            Text("settings.general.menubar.toggle")
                        }

                        Toggle(isOn: $startWithoutWindow)
                        {
                            Text("settings.general.menubar.start-minimized.toggle")
                        }
                        .padding([.leading])
                        .disabled(!showInMenuBar)
                        .onChange(of: showInMenuBar)
                        { newValue in
                            if newValue == false
                            {
                                startWithoutWindow = false
                            }
                        }
                    }
                } label: {
                    Text("settings.general.menubar")
                }

                LabeledContent
                {
                    LaunchAtLogin.Toggle
                    {
                        Text("settings.general.launch-at-login.toggle")
                    }
                } label: {
                    Text("settings.general.launch-at-login")
                }
            }
        }
    }
}
