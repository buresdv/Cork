//
//  Top Packages Tracker.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI

@MainActor
class TopPackagesTracker: ObservableObject, Sendable
{
    @AppStorage("sortTopPackagesBy") var sortTopPackagesBy: TopPackageSorting = .mostDownloads

    @Published var topFormulae: [TopPackage] = .init()
    @Published var topCasks: [TopPackage] = .init()

    var sortedTopFormulae: [TopPackage]
    {
        switch sortTopPackagesBy
        {
        case .mostDownloads:
            return topFormulae.sorted(by: { $0.packageDownloads > $1.packageDownloads })
        case .fewestDownloads:
            return topFormulae.sorted(by: { $0.packageDownloads < $1.packageDownloads })
        case .random:
            return topFormulae.shuffled()
        }
    }

    var sortedTopCasks: [TopPackage]
    {
        switch sortTopPackagesBy
        {
        case .mostDownloads:
            return topCasks.sorted(by: { $0.packageDownloads > $1.packageDownloads })
        case .fewestDownloads:
            return topCasks.sorted(by: { $0.packageDownloads < $1.packageDownloads })
        case .random:
            return topCasks.shuffled()
        }
    }
}
