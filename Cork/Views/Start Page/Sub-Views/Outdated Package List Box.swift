//
//  Updater Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct OutdatedPackageListBox: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var body: some View
    {
        GroupBox
        {
            Grid
            {
                GridRow(alignment: .firstTextBaseline)
                {
                    VStack(alignment: .leading)
                    {
                        GroupBoxHeadlineGroupWithArbitraryContent(image: outdatedPackageTracker.outdatedPackages.count == 1 ? "square.and.arrow.down" : "square.and.arrow.down.on.square")
                        {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(String.localizedPluralString("start-page.updates.count", outdatedPackageTracker.outdatedPackages.count))
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    if outdatedPackageTracker.outdatedPackages.filter({ $0.isMarkedForUpdating }).count == outdatedPackageTracker.outdatedPackages.count
                                    {
                                        Button
                                        {
                                            appState.isShowingUpdateSheet = true
                                        } label: {
                                            Text("start-page.updates.action")
                                        }
                                    } else {
                                        Button {
                                            appState.isShowingIncrementalUpdateSheet = true
                                        } label: {
                                            Text("Update \(outdatedPackageTracker.outdatedPackages.filter({ $0.isMarkedForUpdating }).count) Packages")
                                        }
                                        .disabled(outdatedPackageTracker.outdatedPackages.filter({ $0.isMarkedForUpdating }).count == 0)

                                    }
                                    
                                }
                                
                                DisclosureGroup
                                {
                                    List
                                    {
                                        ForEach(outdatedPackageTracker.outdatedPackages, id: \.self)
                                        { outdatedPackage in
                                            Toggle(outdatedPackage.packageName, isOn: Binding<Bool>(
                                                get: {
                                                    return outdatedPackage.isMarkedForUpdating
                                                }, set: {
                                                    if let index = outdatedPackageTracker.outdatedPackages.firstIndex(where: { $0.id == outdatedPackage.id })
                                                    {
                                                        outdatedPackageTracker.outdatedPackages[index].isMarkedForUpdating = $0
                                                    }
                                                }
                                            ))
                                        }
                                    }
                                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                                    .frame(height: 100)
                                } label: {
                                    Text("start-page.updates.list")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
