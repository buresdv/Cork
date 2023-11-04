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
    
    @State private var cachedDownloads: [CachedDownload] = .init()

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
            
            if !cachedDownloads.isEmpty
            {
                Chart
                {
                    ForEach(cachedDownloads)
                    { cachedPackage in
                        BarMark(
                            x: .value("start-page.cached-downloads.graph.size", cachedPackage.sizeInBytes)
                        )
                        .foregroundStyle(by: .value("start-page.cached-downloads.graph.package-name", cachedPackage.packageName))
                        .annotation(position: .overlay, alignment: .center) {
                            Text(cachedPackage.packageName)
                                .foregroundColor(.white)
                                .font(.system(size: 10))
                        }
                        
                        /// Insert the separators between the bars, unless it's the last one. Then don't insert the divider
                        if cachedPackage.packageName != cachedDownloads.last?.packageName
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
        .task(priority: .background) 
        {
            await loadCachedDownloads()
        }
    }
    
    private func loadCachedDownloads() async
    {
        
        let smallestDispalyableSize: Int = Int(appState.cachedDownloadsFolderSize / 50)
        let largestDisplayableSize: Int = Int(appState.cachedDownloadsFolderSize / 50)
        
        var packagesThatAreTooSmallToDisplaySize: Int = 0
        
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
            
            if itemSize < smallestDispalyableSize
            {
                packagesThatAreTooSmallToDisplaySize = packagesThatAreTooSmallToDisplaySize + itemSize
            }
            else
            {
                cachedDownloads.append(.init(packageName: itemName, sizeInBytes: itemSize))
            }
            
            print("Others size: \(packagesThatAreTooSmallToDisplaySize)")
        }
        
        cachedDownloads.append(.init(packageName: "start-page.cached-downloads.graph.other-smaller-packages", sizeInBytes: packagesThatAreTooSmallToDisplaySize))
        
        print("Cached downloads contents: \(cachedDownloads)")
        
        cachedDownloads = cachedDownloads.sorted(by: { $0.sizeInBytes < $1.sizeInBytes })
    }
}
