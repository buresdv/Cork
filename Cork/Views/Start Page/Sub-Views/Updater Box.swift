//
//  Updater Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct UpdaterBox: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
    @State private var isOutdatedPackageListExpanded: Bool = false
    
    var body: some View {
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
                            HStack(alignment: .firstTextBaseline)
                            {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String.localizedPluralString("start-page.updates.count", outdatedPackageTracker.outdatedPackageNames.count))
                                        .font(.headline)
                                    DisclosureGroup(isExpanded: $isOutdatedPackageListExpanded)
                                    {} label: {
                                        Text("start-page.updates.list")
                                            .font(.subheadline)
                                    }

                                    if isOutdatedPackageListExpanded
                                    {
                                        List
                                        {
                                            ForEach(outdatedPackageTracker.outdatedPackageNames, id: \.self) { outdatedPackageName in
                                                Text(outdatedPackageName)
                                            }
                                        }
                                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                                        .frame(height: 100)
                                    }
                                }
                                
                                Spacer()
                                
                                Button
                                {
                                    appState.isShowingUpdateSheet = true
                                } label: {
                                    Text("start-page.updates.action")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
