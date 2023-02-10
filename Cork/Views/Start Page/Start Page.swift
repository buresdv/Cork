//
//  Start Page.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

struct StartPage: View
{
    @ObservedObject var brewData: BrewDataStorage
    
    @State var updateProgressTracker: UpdateProgressTracker
    
    @State var upgradeablePackages: [BrewPackage] = .init()

    @State private var isDisclosureGroupExpanded: Bool = false

    var body: some View
    {
        VStack
        {
            if upgradeablePackages.isEmpty
            {
                ProgressView
                {
                    Text("Checking for Package Updates...")
                }
            }
            else
            {
                VStack
                {
                    VStack(alignment: .leading)
                    {
                        Text("Homebrew Status")
                            .font(.title)

                        GroupBox
                        {
                            if upgradeablePackages.count == 0
                            {
                                GroupBoxHeadlineGroup(title: "You are all up-to-date", mainText: "There are no packages to update")
                            }
                            else
                            {
                                Grid
                                {
                                    GridRow(alignment: .firstTextBaseline)
                                    {
                                        if upgradeablePackages.count == 1
                                        {
                                            VStack(alignment: .leading)
                                            {
                                                Text("There is 1 outdated package")
                                                    .font(.headline)
                                                DisclosureGroup(isExpanded: $isDisclosureGroupExpanded)
                                                {} label: {
                                                    Text("Outdated packages")
                                                        .font(.subheadline)
                                                }

                                                if isDisclosureGroupExpanded
                                                {
                                                    List(upgradeablePackages)
                                                    { package in
                                                        Text(package.name)
                                                    }
                                                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                                                    .frame(maxHeight: 100)
                                                }
                                            }
                                        }
                                        else
                                        {
                                            VStack(alignment: .leading)
                                            {
                                                Text("There are \(upgradeablePackages.count) outdated packages")
                                                    .font(.headline)
                                                DisclosureGroup(isExpanded: $isDisclosureGroupExpanded)
                                                {} label: {
                                                    Text("Outdated packages")
                                                        .font(.subheadline)
                                                }

                                                if isDisclosureGroupExpanded
                                                {
                                                    List(upgradeablePackages)
                                                    { package in
                                                        Text(package.name)
                                                    }
                                                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                                                    .frame(maxHeight: 100)
                                                }
                                            }
                                        }

                                        Button
                                        {
                                            upgradeBrewPackages(updateProgressTracker)
                                        } label: {
                                            Text("Update")
                                        }
                                    }
                                }
                            }
                        }

                        GroupBox
                        {
                            Grid(alignment: .leading)
                            {
                                GridRow(alignment: .firstTextBaseline) {
                                    GroupBoxHeadlineGroup(title: "You have \(brewData.installedFormulae.count) Formulae installed", mainText: "Formulae are usually apps that you run in a terminal")
                                }
                                
                                Divider()
                                
                                GridRow(alignment: .firstTextBaseline) {
                                    GroupBoxHeadlineGroup(title: "You have \(brewData.installedCasks.count) Casks instaled", mainText: "Casks are usually graphical apps")
                                }
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .onAppear
        {
            Task
            {
                upgradeablePackages = await getListOfUpgradeablePackages()
            }
        }
    }
}
