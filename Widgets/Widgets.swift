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
            MinimalHomebrewPackage(name: "Cork", type: .cask),
        ])
    }

    func getSnapshot(in _: Context, completion: @escaping (InstalledPackagesEntry) -> Void)
    {
        let entry = InstalledPackagesEntry(date: Date(), packages: [
            MinimalHomebrewPackage(name: "Cork", type: .cask)
        ])
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void)
    {
        Task
        {
            var entries: [InstalledPackagesEntry] = []
            
            let resultOfPackagesIntent: [MinimalHomebrewPackage] = try! await GetInstalledPackagesIntent().perform().value!
            
            entries.append(.init(date: .now, packages: resultOfPackagesIntent))
            
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
        VStack {
            Text("Emoji:")
            Text(String(entry.packages.count))
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
    let kind: String = .installedPackagesWidget

    var body: some WidgetConfiguration
    {
        StaticConfiguration(kind: kind, provider: InstalledPackagesProvider())
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
    }
}
