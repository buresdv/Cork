//
//  Cached Downloads Folder Info Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI
import Charts

struct CachedDownloadsFolderInfoBox: View
{    
    @EnvironmentObject var appState: AppState

    var body: some View
    {
        VStack
        {
            HStack
            {
                GroupBoxHeadlineGroup(
                    image: "archivebox",
                    title: "start-page.cached-downloads-\(appState.cachedDownloadsFolderSize.formatted(.byteCount(style: .file)))",
                    mainText: "start-page.cached-downloads.description"
                )

                Spacer()

                Button
                {
                    appState.isShowingFastCacheDeletionMaintenanceView = true
                } label: {
                    Text("start-page.cached-downloads.action")
                }
            }
            
            if !appState.cachedDownloads.isEmpty
            {
                Chart
                {
                    ForEach(appState.cachedDownloads)
                    { cachedPackage in
                        BarMark(
                            x: .value("start-page.cached-downloads.graph.size", cachedPackage.sizeInBytes)
                        )
                        .foregroundStyle(by: .value("start-page.cached-downloads.graph.package-name", cachedPackage.packageName))
                        .annotation(position: .overlay, alignment: .center) {
                            Text(cachedPackage.packageName)
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        
                        /// Insert the separators between the bars, unless it's the last one. Then don't insert the divider
                        if cachedPackage.packageName != appState.cachedDownloads.last?.packageName
                        {
                            BarMark(
                                x: .value("start-page.cached-downloads.graph.size", appState.cachedDownloadsFolderSize / 500)
                            )
                            .foregroundStyle(Color.white)
                        }
                    }
                }
                .chartXAxis(.hidden)
                .chartXScale(type: .linear)
                .chartLegend(.hidden)
                .cornerRadius(2)
                .frame(height: 20)
            }
        }
    }
}
