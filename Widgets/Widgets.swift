//
//  Widgets.swift
//  Widgets
//
//  Created by David Bureš on 25.05.2024.
//

import SwiftUI
import WidgetKit

private extension String
{
    static var installedPackagesWidget: String
    {
        return "InstalledPackagesWidget"
    }
}

struct InstalledPackagesProvider: TimelineProvider
{
    func placeholder(in _: Context) -> InstalledPackagesEntry
    {
        InstalledPackagesEntry(date: Date(), packages: [
            MinimalHomebrewPackage(name: "Cork", type: .cask, installedIntentionally: true),
        ])
    }

    func getSnapshot(in _: Context, completion: @escaping (InstalledPackagesEntry) -> Void)
    {
        let entry = InstalledPackagesEntry(date: Date(), packages: [
            MinimalHomebrewPackage(name: "Cork", type: .cask, installedIntentionally: true)
        ])
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void)
    {
        Task
        {
            var entries: [InstalledPackagesEntry] = []
            
            do
            {
                let resultOfPackagesIntent: [MinimalHomebrewPackage] = try await GetInstalledPackagesIntent().perform().value ?? .init()
                
                entries.append(.init(date: .now, packages: resultOfPackagesIntent))
            }
            catch let packageLoadingError
            {
                WidgetConstants.logger.error("Error while retrieving packages: \(packageLoadingError)")
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct InstalledPackagesWidgetView: View
{
    var entry: InstalledPackagesProvider.Entry
    
    var body: some View
    {
        VStack 
        {
            if !entry.packages.isEmpty
            {
                Text("widget.installed-packages.count.title")
                Text(String(entry.packages.count))
            }
            else
            {
                Text("widget.installed-packages.could-not-load")
            }
        }
    }
}

struct InstalledPackagesEntry: TimelineEntry
{
    let date: Date

    let packages: [MinimalHomebrewPackage]
}

struct InstalledPackagesWidget: Widget
{
    var body: some WidgetConfiguration
    {
        StaticConfiguration(kind: .installedPackagesWidget, provider: InstalledPackagesProvider())
        { entry in
            if #available(macOS 14.0, *)
            {
                InstalledPackagesWidgetView(entry: entry)
                    .containerBackground(.cyan.gradient, for: .widget)
            }
            else
            {
                InstalledPackagesWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("widget.installed-packages.name")
        .description("widget.installed-packages.description")
        .supportedFamilies([.systemLarge, .systemMedium])
    }
}
