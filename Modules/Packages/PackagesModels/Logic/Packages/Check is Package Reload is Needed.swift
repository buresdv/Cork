//
//  Check is Package Reload is Needed.swift
//  CorkModels
//
//  Created by David Bureš - P on 04.08.2026.
//

import CorkShared
import Foundation

public extension BrewPackagesTracker
{
    func checkIfReloadIsNeeded(for packageType: BrewPackage.PackageType) async -> Bool
    {
        switch packageType
        {
        case .formula:
            return await self.checkIfFormulaReloadIsNeeded()
        case .cask:
            return await self.checkIfCaskReloadIsNeeded()
        }
    }

    internal func debugReloadComparison(for packageType: BrewPackage.PackageType) async -> String
    {
        let onDisk = await getOnlyBasicInformationAboutPackagesOnDisk(for: getPackageURLsInFolder(for: packageType) ?? .empty)
        let loaded = await getOnlyBasicInformationAboutLoadedPackages(for: packageType)

        return """
        \(packageType):
          on disk: \(onDisk.count) packages, in memory: \(loaded.count) packages
          only on disk: \(onDisk.subtracting(loaded))
          only in memory: \(loaded.subtracting(onDisk))
        """
    }

    internal struct BasicPackageInfo: Hashable
    {
        let packageName: String
        let packageVersions: Set<String>?
    }

    internal func checkIfFormulaReloadIsNeeded() async -> Bool
    {
        return await getOnlyBasicInformationAboutPackagesOnDisk(for: getPackageURLsInFolder(for: .formula) ?? .empty) != getOnlyBasicInformationAboutLoadedPackages(for: .formula)
    }

    internal func checkIfCaskReloadIsNeeded() async -> Bool
    {
        return await getOnlyBasicInformationAboutPackagesOnDisk(for: getPackageURLsInFolder(for: .cask) ?? .empty) != getOnlyBasicInformationAboutLoadedPackages(for: .cask)
    }

    internal func getOnlyBasicInformationAboutLoadedPackages(for packageType: BrewPackage.PackageType) async -> Set<BasicPackageInfo>
    {
        let relevantTrackerContents: Set<BrewPackage> = switch packageType
        {
        case .formula:
            self.successfullyLoadedFormulae
        case .cask:
            self.successfullyLoadedCasks
        }

        return Set(relevantTrackerContents.map
        { installedPackage in
            BasicPackageInfo(
                packageName: installedPackage.name(withPrecision: .precise),
                packageVersions: Set(installedPackage.versions)
            )
        })
    }

    /// Get names of package folders, along with their versions
    internal func getOnlyBasicInformationAboutPackagesOnDisk(for folderContents: [URL]) async -> Set<BasicPackageInfo>
    {
        return Set(folderContents.map
        { packageURL in
            let packageVersions: Set<String>? = try? Set(
                packageURL
                    .getContents(options: [.skipsHiddenFiles])
                    .map(\.lastPathComponent)
            )

            return .init(
                packageName: packageURL.packageNameFromURL(),
                packageVersions: packageVersions ?? .none
            )
        })
    }

    /// Get names of package folders
    internal func getPackageURLsInFolder(for packageType: BrewPackage.PackageType) async -> [URL]?
    {
        return try? packageType.parentFolder
            .getContents(options: [.skipsHiddenFiles])
            .filter(\.isActualPackageFolder)
    }
}
