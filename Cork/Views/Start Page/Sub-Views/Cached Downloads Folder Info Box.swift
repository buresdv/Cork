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
    private struct CachedDownload: Identifiable, Hashable {
        
        var id: String { packageName }
        
        let packageName: String
        let sizeInBytes: Int
    }
    
    @EnvironmentObject var appState: AppState
    
    @State private var cachedDownloads: Set<CachedDownload> = .init()

    var body: some View
    {
        VStack
        {
            HStack
            {
                VStack(alignment: .leading)
                {
                    GroupBoxHeadlineGroup(
                        image: "archivebox",
                        title: "start-page.cached-downloads-\(appState.cachedDownloadsFolderSize.formatted(.byteCount(style: .file)))",
                        mainText: "start-page.cached-downloads.description"
                    )
                    
                    if !cachedDownloads.isEmpty
                    {
                        Chart(cachedDownloads.sorted(by: { $0.sizeInBytes < $1.sizeInBytes }))
                        {
                            BarMark(
                                x: .value("start-page.cached-downloads.graph.size", $0.sizeInBytes)
                            )
                            .foregroundStyle(by: .value("start-page.cached-downloads.graph.package-name", $0.packageName))
                        }
                        .chartXAxis(.hidden)
                        .chartYScale(type: .log)
                    }
                }

                Spacer()

                Button
                {
                    appState.isShowingFastCacheDeletionMaintenanceView = true
                } label: {
                    Text("start-page.cached-downloads.action")
                }
            }
        }
        .task(priority: .background) 
        {
            await loadCachedDownloads()
        }
    }
    
    private func loadCachedDownloads() async
    {
        guard let cachedDownloadsFolderContents: [URL] = try? FileManager.default.contentsOfDirectory(at: AppConstants.brewCachedDownloadsPath, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else
        {
            return
        }
        
        let usableCachedDownloads: [URL] = cachedDownloadsFolderContents.filter({ $0.pathExtension != "json" })
        
        for usableCachedDownload in usableCachedDownloads 
        {
            guard let itemName: String = try? regexMatch(from: usableCachedDownload.lastPathComponent, regex: "(?<=--)(.*?)(?=\\.)") else
            {
                return
            }
            
            print("Temp item name: \(itemName)")
            
            guard let itemAttributes = try? FileManager.default.attributesOfItem(atPath: usableCachedDownload.path) else
            {
                return
            }
            
            guard let itemSize = itemAttributes[.size] as? Int else
            {
                return
            }
            
            cachedDownloads.insert(.init(packageName: itemName, sizeInBytes: itemSize))
        }
        
        print(print("Cached downloads contents: \(cachedDownloads)"))
    }
}
