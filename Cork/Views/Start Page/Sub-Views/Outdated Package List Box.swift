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
                        GroupBoxHeadlineGroupWithArbitraryContent(image: outdatedPackageTracker.outdatedPackageNames.count == 1 ? "square.and.arrow.down" : "square.and.arrow.down.on.square")
                        {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(String.localizedPluralString("start-page.updates.count", outdatedPackageTracker.outdatedPackageNames.count))
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Button
                                    {
                                        appState.isShowingUpdateSheet = true
                                    } label: {
                                        Text("start-page.updates.action")
                                    }
                                }
                                
                                DisclosureGroup
                                {
                                    List
                                    {
                                        ForEach(outdatedPackageTracker.outdatedPackageNames, id: \.self)
                                        { outdatedPackageName in
                                            Text(outdatedPackageName)
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
