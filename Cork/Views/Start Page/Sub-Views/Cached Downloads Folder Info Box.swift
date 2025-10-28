//
//  Cached Downloads Folder Info Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import Charts
import SwiftUI

struct CachedDownloadsFolderInfoBox: View
{
    @Environment(AppState.self) var appState: AppState

    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    var body: some View
    {
        VStack
        {
            HStack
            {
                GroupBoxHeadlineGroup(
                    image: "archivebox",
                    title: "start-page.cached-downloads-\(cachedDownloadsTracker.cachedDownloadsSize.formatted(.byteCount(style: .file)))",
                    mainText: "start-page.cached-downloads.description"
                )

                Spacer()

                DeleteCachedDownloadsButton(appState: appState)
                    .labelStyle(.titleOnly)
            }

            if !cachedDownloadsTracker.cachedDownloads.isEmpty
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Chart
                    {
                        ForEach(cachedDownloadsTracker.cachedDownloads)
                        { cachedPackage in

                            let markAccessibilityLabel: LocalizedStringKey =
                            {
                                switch cachedPackage.packageType
                                {
                                case .none:
                                    return "accessibility.label.package-type.unknown"
                                case .some(let packageType):
                                    switch packageType
                                    {
                                    case .formula:
                                        return BrewPackage.PackageType.formula.accessibilityLabel
                                    case .cask:
                                        return BrewPackage.PackageType.cask.accessibilityLabel
                                    case .other:
                                        return "accessibility.label.package-type.unimplemented"
                                    case .unknown:
                                        return "accessibility.label.package-type.unknown"
                                    }
                                }
                            }()

                            BarMark(
                                x: .value("start-page.cached-downloads.graph.size", cachedPackage.sizeInBytes)
                            )
                            .foregroundStyle(cachedPackage.packageType?.color ?? .mint)
                            .annotation(position: .overlay, alignment: .center)
                            {
                                Text(cachedPackage.packageName)
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .accessibilityHidden(true)
                            }
                            .accessibilityLabel(markAccessibilityLabel)
                            .accessibilityValue(cachedPackage.sizeInBytes.formatted(.byteCount(style: .file)))

                            /// Insert the separators between the bars, unless it's the last one. Then don't insert the divider
                            if cachedPackage.packageName != cachedDownloadsTracker.cachedDownloads.last?.packageName
                            {
                                BarMark(
                                    x: .value("start-page.cached-downloads.graph.size", cachedDownloadsTracker.cachedDownloadsSize / 350)
                                )
                                .foregroundStyle(Color.white)
                                .accessibilityHidden(true)
                            }
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartXScale(type: .linear)
                    .chartForegroundStyleScale([
                        BrewPackage.PackageType.formula: .purple,
                        BrewPackage.PackageType.cask: .orange
                    ])
                    .cornerRadius(2)
                    .frame(height: 20)
                    .chartLegend(.hidden)
                    .accessibilityElement(children: .contain)

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
    func chartLegendItem(item: CachedDownload.CachedDownloadType) -> some View
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
