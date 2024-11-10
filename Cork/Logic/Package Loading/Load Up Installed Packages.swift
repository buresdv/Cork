//
//  Load Up Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 10.11.2024.
//

import CorkShared
import Foundation

extension BrewDataStorage
{
    /// Parent function for loading installed packages from disk
    /// Abstracts away the function ``loadInstalledPackagesFromFolder(packageTypeToLoad:)``, transforming errors thrown by ``loadInstalledPackagesFromFolder(packageTypeToLoad:)`` into displayable errors
    /// - Parameters:
    ///   - packageTypeToLoad: Which ``PackageType`` to load
    ///   - appState: ``AppState`` used to display loading errors
    /// - Returns: A set of loaded ``BrewPackage``s for the specified ``PackageType``
    func loadInstalledPackages(
        packageTypeToLoad: PackageType, appState: AppState
    ) async -> Set<BrewPackage>?
    {
        /// Start tracking when loading started
        let timeLoadingStarted: Date = .now
        AppConstants.shared.logger.debug(
            "Started \(packageTypeToLoad.rawValue, privacy: .public) loading task at \(timeLoadingStarted, privacy: .public)"
        )

        /// Calculate how long loading took
        defer
        {
            AppConstants.shared.logger.debug("Finished \(packageTypeToLoad.rawValue, privacy: .public). Took \(timeLoadingStarted.timeIntervalSince(.now), privacy: .public)")
        }

        do
        {
            return try await self.loadInstalledPackagesFromFolder(
                packageTypeToLoad: packageTypeToLoad)
        }
        catch let packageLoadingError
        {
            switch packageLoadingError
            {
            case .couldNotReadContentsOfParentFolder(let loadingError):
                appState.showAlert(errorToShow: .couldNotGetContentsOfPackageFolder(loadingError))
            case .failedWhileLoadingPackages:
                appState.showAlert(
                    errorToShow: .couldNotLoadAnyPackages(packageLoadingError))
            case .failedWhileLoadingCertainPackage(
                let offendingPackage, let offendingPackageURL, let failureReason
            ):
                appState.showAlert(
                    errorToShow: .couldNotLoadCertainPackage(
                        offendingPackage, offendingPackageURL,
                        failureReason: failureReason
                    ))
            case .packageDoesNotHaveAnyVersionsInstalled(let offendingPackage):
                appState.showAlert(
                    errorToShow: .installedPackageHasNoVersions(
                        corruptedPackageName: offendingPackage))
            case .packageIsNotAFolder(let offendingFile, let offendingFileURL):
                appState.showAlert(
                    errorToShow: .installedPackageIsNotAFolder(
                        itemName: offendingFile, itemURL: offendingFileURL
                    ))
            }

            return nil
        }
    }
}

private extension BrewDataStorage
{
    /// Load packages from disk, and convert them into ``BrewPackage``s
    func loadInstalledPackagesFromFolder(
        packageTypeToLoad: PackageType
    ) async throws(PackageLoadingError) -> Set<BrewPackage>?
    {
        do
        {
            let urlsInParentFolder: [URL] = try getContentsOfFolder(targetFolder: packageTypeToLoad.parentFolder, options: [.skipsHiddenFiles])
            
            AppConstants.shared.logger.debug("Loaded contents of folder: \(urlsInParentFolder)")
            
            return nil
        }
        catch let parentFolderReadingError
        {
            AppConstants.shared.logger.error("Couldn't get contents of folder \(packageTypeToLoad.parentFolder, privacy: .public)")

            throw .couldNotReadContentsOfParentFolder(failureReason: parentFolderReadingError.localizedDescription)
        }
    }
}
