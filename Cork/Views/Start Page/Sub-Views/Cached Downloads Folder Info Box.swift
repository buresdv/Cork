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
                VStack(alignment: .leading, spacing: 10)
                {
                    Chart
                    {
                        ForEach(appState.cachedDownloads)
                        { cachedPackage in
                            BarMark(
                                x: .value("start-page.cached-downloads.graph.size", cachedPackage.sizeInBytes)
                            )
                            .foregroundStyle(cachedPackage.packageType?.color ?? .mint)
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
                    .chartForegroundStyleScale([
                        PackageType.formula: .purple,
                        PackageType.cask: .orange
                    ])
                    .cornerRadius(2)
                    .frame(height: 20)
                    .chartLegend(.hidden)
                    
                    HStack(alignment: .center, spacing: 10)
                    {
                        chartLegendItem(item: .formula)
                        chartLegendItem(item: .cask)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func chartLegendItem(item: CachedDownloadType) -> some View
    {
        HStack(alignment: .center, spacing: 4)
        {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(item.color)
            
            Text(item.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
