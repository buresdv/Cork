//
//  General Pane.swift
//  Cork
//
//  Created by David Bureš on 15.02.2023.
//

import LaunchAtLogin
import SwiftUI
import CorkShared
import Defaults

struct GeneralPane: View
{
    @Default(.sortPackagesBy) var sortPackagesBy: PackageSortingOptions
    @Default(.displayAdvancedDependencies) var displayAdvancedDependencies

    @Default(.displayOnlyIntentionallyInstalledPackagesByDefault) var displayOnlyIntentionallyInstalledPackagesByDefault: Bool

    @Default(.caveatDisplayOptions) var caveatDisplayOptions
    @Default(.showDescriptionsInSearchResults) var showDescriptionsInSearchResults

    @AppStorage("outdatedPackageInfoDisplayAmount") var outdatedPackageInfoDisplayAmount: OutdatedPackageInfoAmount = .all
    @AppStorage("showOldVersionsInOutdatedPackageList") var showOldVersionsInOutdatedPackageList: Bool = true

    @AppStorage("enableRevealInFinder") var enableRevealInFinder: Bool = false
    @AppStorage("enableSwipeActions") var enableSwipeActions: Bool = false
    @AppStorage("enableExtraAnimations") var enableExtraAnimations: Bool = true

    @Default(.showSearchFieldForDependenciesInPackageDetails) var showSearchFieldForDependenciesInPackageDetails
    @Default(.showInMenuBar) var showInMenuBar
    @Default(.startWithoutWindow) var startWithoutWindow: Bool

    @AppStorage("defaultBackupDateFormat") var defaultBackupDateFormat: Date.FormatStyle.DateStyle = .numeric

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                Picker(selection: $sortPackagesBy) {
                    ForEach(PackageSortingOptions.allCases)
                    { packageSortingOption in
                        Text(packageSortingOption.description)
                    }
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
                    Text("settings.general.package-notes")
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
                    VStack(alignment: .leading, spacing: 6)
                    {
                        Picker(selection: $outdatedPackageInfoDisplayAmount)
                        {
                            ForEach(OutdatedPackageInfoAmount.allCases)
                            { infoAmount in
                                Text(infoAmount.localizedName)
                                    .tag(infoAmount)
                            }
                        } label: {
                            Text("settings.general.outdated-packages.info-amount")
                        }
                        .labelsHidden()

                        Toggle(isOn: $showOldVersionsInOutdatedPackageList)
                        {
                            Text("settings.general.outdated-packages.also-show-old-versions")
                        }
                        .disabled(outdatedPackageInfoDisplayAmount != .versionOnly)
                        .padding([.leading])
                        .onChange(of: outdatedPackageInfoDisplayAmount)
                        { newValue in
                            switch newValue
                            {
                            case .none:
                                showOldVersionsInOutdatedPackageList = false
                            case .versionOnly:
                                break
                            case .all:
                                showOldVersionsInOutdatedPackageList = true
                            }
                        }
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

                        Toggle(isOn: $enableSwipeActions)
                        {
                            Text("settings.general.package-details.enable-swipe-actions.toggle")
                        }

                        Toggle(isOn: $enableExtraAnimations)
                        {
                            Text("settings.geeral.package-details.enable-extra-animations.toggle")
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

                        // TODO: Enable again once Apple fixes issue raised in ticket #408
                        /*
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
                          */
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

                LabeledContent {
                    VStack(alignment: .leading, spacing: 6)
                    {
                        Picker(selection: $defaultBackupDateFormat)
                        {
                            ForEach(Date.FormatStyle.DateStyle.allCases)
                            { dateStyle in
                                Text(dateStyle.localizedDescription)
                            }
                        } label: {
                            Text("settings.general.backup-date-format")
                        }
                        .labelsHidden()
                        
                        if let demoDate: Date = Calendar.current.date(from: .init(calendar: .current, timeZone: .gmt, year: 2022, month: 7, day: 3))
                        {
                            if defaultBackupDateFormat != .omitted
                            {
                                Text(demoDate.formatted(date: defaultBackupDateFormat, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(Color(nsColor: NSColor.systemGray))
                            }
                        }
                    }
                } label: {
                    Text("settings.general.backup-date-format")
                }
            }
        }
    }
}
