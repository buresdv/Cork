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
            AppConstants.shared.logger.debug("Finished \(packageTypeToLoad.rawValue, privacy: .public) loading task. Took \(timeLoadingStarted.timeIntervalSince(.now), privacy: .public)")
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
            /// This gets URLs to all package folders in a folder.
            /// `/opt/homebrew/Caskroom/microsoft-edge/`
            let urlsInParentFolder: [URL] = try getContentsOfFolder(targetFolder: packageTypeToLoad.parentFolder, options: [.skipsHiddenFiles])

            AppConstants.shared.logger.debug("Loaded contents of folder: \(urlsInParentFolder)")

            let packageLoader: Set<BrewPackage> = await withTaskGroup(of: BrewPackage?.self, returning: Set<BrewPackage>.self)
            { taskGroup in
                for packageURL in urlsInParentFolder
                {
                    guard taskGroup.addTaskUnlessCancelled(priority: .high, operation: {
                        try? await self.loadInstalledPackage(packageURL: packageURL)
                    })
                    else
                    {
                        break
                    }
                }

                var loadedPackages: Set<BrewPackage> = .init()

                for await loadedPackage in taskGroup
                {
                    if let loadedPackage
                    {
                        loadedPackages.insert(loadedPackage)
                    }
                }

                return loadedPackages
            }

            return packageLoader
        }
        catch let parentFolderReadingError
        {
            AppConstants.shared.logger.error("Couldn't get contents of folder \(packageTypeToLoad.parentFolder, privacy: .public)")

            throw .couldNotReadContentsOfParentFolder(failureReason: parentFolderReadingError.localizedDescription)
        }
    }

    /// For a given `URL` to a package folder containing the various versions of the package, parse the package contained within
    /// - Parameter packageURL: `URL` to the package parent folder
    /// - Returns: A parsed package of the ``BrewPackage`` type
    func loadInstalledPackage(packageURL: URL) async throws(PackageLoadingError) -> BrewPackage
    {
        /// Get the name of the package - at this stage, it is the last path component
        let packageName: String = packageURL.lastPathComponent

        /// Check if we're not trying to read versions in the Cellar or Caskroom folder itself - this usually means Homebrew is broken
        guard packageName != "Cellar", packageName != "Caskroom"
        else
        {
            AppConstants.shared.logger.error("The last path component of the requested URL is the package container folder itself - perhaps a misconfigured package folder? Tried to load URL \(packageURL)")

            switch packageURL.packageType
            {
            case .formula:
                throw PackageLoadingError.failedWhileLoadingPackages(failureReason: String(localized: "error.package-loading.last-path-component-of-checked-package-url-is-folder-containing-packages-itself.formulae"))
            case .cask:
                throw PackageLoadingError.failedWhileLoadingPackages(failureReason: String(localized: "error.package-loading.last-path-component-of-checked-package-url-is-folder-containing-packages-itself.casks"))
            }
        }

        /// Let's try to parse the package now
        do
        {
            /// Gets URL to installed versions of a package provided as ``packageURL``
            /// `/opt/homebrew/Cellar/cmake/3.30.5`, `/opt/homebrew/Cellar/cmake/3.30.4`
            let versionURLs: [URL] = try getContentsOfFolder(targetFolder: packageURL, options: [.skipsHiddenFiles])

            /// Gets the name of the version, which at this stage is the last path component of the `versionURLs` URL
            let versionNamesForPackage: [String] = versionURLs.map
            { versionURL in
                versionURL.lastPathComponent
            }

            AppConstants.shared.logger.debug("Package \(packageURL.lastPathComponent) has these versions available: \(versionURLs.map { $0.absoluteString }.joined(separator: ", "))")

            do
            {
                let wasPackageInstalledIntentionally: Bool = try await packageURL.checkIfPackageWasInstalledIntentionally(versionURLs: versionURLs)

                return .init(
                    name: packageName,
                    type: packageURL.packageType,
                    installedOn: packageURL.creationDate,
                    versions: versionNamesForPackage,
                    installedIntentionally: wasPackageInstalledIntentionally,
                    sizeInBytes: packageURL.directorySize
                )
            }
            catch let intentionalInstallationDiscoveryError
            {
                switch intentionalInstallationDiscoveryError
                {
                case .failedToDetermineMostRelevantVersion(let packageURL):
                    throw PackageLoadingError.failedWhileLoadingCertainPackage(packageName, packageURL, failureReason: String(localized: "error.package-loading.could-not-load-version-to-check-from-available-versions"))
                case .failedToReadInstallationRecepit(let packageURL):
                    throw PackageLoadingError.failedWhileLoadingCertainPackage(packageName, packageURL, failureReason: String(localized: "error.package-loading.could-not-convert-contents-of-install-receipt-to-data"))
                case .failedToParseInstallationReceipt(let packageURL):
                    throw PackageLoadingError.failedWhileLoadingCertainPackage(packageName, packageURL, failureReason: String(localized: "error.package-loading.could-not-decode-installa-receipt"))
                case .installationReceiptMissingCompletely(let packageURL):
                    throw PackageLoadingError.failedWhileLoadingCertainPackage(packageName, packageURL, failureReason: String(localized: "error.package-loading.missing-install-receipt"))
                case .unexpectedFolderName(let packageURL):
                    throw PackageLoadingError.failedWhileLoadingCertainPackage(packageName, packageURL, failureReason: String(localized: "error.package-loading.unexpected-folder-name"))
                }
            }
        }
        catch let loadingError
        {
            AppConstants.shared.logger.error("Failed while loading package \(packageURL.lastPathComponent, privacy: .public): \(loadingError.localizedDescription)")

            throw .failedWhileLoadingCertainPackage(packageURL.lastPathComponent, packageURL, failureReason: loadingError.localizedDescription)
        }
    }
}
