//
//  Top Packages Tracker.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftUI

@Observable @MainActor
class TopPackagesTracker
{
    @ObservationIgnored @AppStorage("sortTopPackagesBy") var sortTopPackagesBy: TopPackageSorting = .mostDownloads

    var topFormulae: [BrewPackage] = .init()
    var topCasks: [BrewPackage] = .init()

    var sortedTopFormulae: [BrewPackage]
    {
        switch sortTopPackagesBy
        {
        case .mostDownloads:
            return topFormulae.sorted { firstPackage, secondPackage in
                guard let firstPackageDownloadCount = firstPackage.downloadCount, let secondPackageDownloadCount = secondPackage.downloadCount else
                {
                    return .init()
                }
                
                return firstPackageDownloadCount > secondPackageDownloadCount
            }
        case .fewestDownloads:
            return topFormulae.sorted { firstPackage, secondPackage in
                guard let firstPackageDownloadCount = firstPackage.downloadCount, let secondPackageDownloadCount = secondPackage.downloadCount else
                {
                    return .init()
                }
                
                return firstPackageDownloadCount < secondPackageDownloadCount
            }
        case .random:
            return topFormulae.shuffled()
        }
    }

    var sortedTopCasks: [BrewPackage]
    {
        switch sortTopPackagesBy
        {
        case .mostDownloads:
            return topCasks.sorted { firstPackage, secondPackage in
                guard let firstPackageDownloadCount = firstPackage.downloadCount, let secondPackageDownloadCount = secondPackage.downloadCount else
                {
                    return .init()
                }
                
                return firstPackageDownloadCount > secondPackageDownloadCount
            }
        case .fewestDownloads:
            return topCasks.sorted { firstPackage, secondPackage in
                guard let firstPackageDownloadCount = firstPackage.downloadCount, let secondPackageDownloadCount = secondPackage.downloadCount else
                {
                    return .init()
                }
                
                return firstPackageDownloadCount < secondPackageDownloadCount
            }
        case .random:
            return topCasks.shuffled()
        }
    }
}
