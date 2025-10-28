//
//  Load Up Installed Packages.swift
//  Cork
//
//  Created by David Bureš on 10.11.2024.
//

import CorkShared
import Foundation

/// A representation of the loaded ``BrewPackage``s
/// Includes packages that were loaded properly, along those whose loading failed
typealias BrewPackages = Set<Result<BrewPackage, PackageLoadingError>>

extension BrewPackagesTracker
{
    /// Parent function for loading installed packages from disk
    /// Abstracts away the function ``loadInstalledPackagesFromFolder(packageTypeToLoad:)``, transforming errors thrown by ``loadInstalledPackagesFromFolder(packageTypeToLoad:)`` into displayable errors
    /// - Parameters:
    ///   - packageTypeToLoad: Which ``PackageType`` to load
    ///   - appState: ``AppState`` used to display loading errors
    /// - Returns: A set of loaded ``BrewPackage``s for the specified ``PackageType``
    func loadInstalledPackages(
        packageTypeToLoad: BrewPackage.PackageType, appState: AppState
    ) async -> BrewPackages?
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
            case .couldNotReadContentsOfParentFolder(let loadingError, let folderURL):
                AppConstants.shared.logger.error("Failed while loading packages: Could not read contents of parent folder (\(folderURL.path()): \(loadingError)")
                appState.showAlert(errorToShow: .couldNotGetContentsOfPackageFolder(loadingError))
            case .packageDoesNotHaveAnyVersionsInstalled(let packageURL):
                AppConstants.shared.logger.error("Failed while loading packages: Package \(packageURL.packageNameFromURL()) does not have any versions installed")
                appState.showAlert(
                    errorToShow: .installedPackageHasNoVersions(
                        corruptedPackageName: packageURL.packageNameFromURL()))
            case .packageIsNotAFolder(let offendingFile, let offendingFileURL):
                AppConstants.shared.logger.error("Failed while loading packages: Package \(offendingFileURL.path()) is not a folder")
                appState.showAlert(
                    errorToShow: .installedPackageIsNotAFolder(
                        itemName: offendingFile, itemURL: offendingFileURL
                    ))
            case .numberOLoadedPackagesDosNotMatchNumberOfPackageFolders:
                AppConstants.shared.logger.error("Failed while loading packages: Number of loaded packages does not match the number of URLs in package folder")
                appState.showAlert(errorToShow: .numberOfLoadedPackagesDoesNotMatchNumberOfPackageFolders)
            case .triedToThreatFolderContainingPackagesAsPackage(let packageType):
                appState.showAlert(errorToShow: .triedToThreatFolderContainingPackagesAsPackage(packageType: packageType))
            case .failedWhileReadingContentsOfPackageFolder(let folderURL, let reportedError):
                AppConstants.shared.logger.error("Failed while loading packages: Couldn't read contents of package folder \(folderURL) with this error: \(reportedError)")
            case .failedWhileTryingToDetermineIntentionalInstallation(let folderURL, let associatedIntentionalDiscoveryError):
                AppConstants.shared.logger.error("Failed while loading packages: Couldn't determine intentional installation status for package \(folderURL) with this error: \(associatedIntentionalDiscoveryError.localizedDescription)")
            }

            switch packageTypeToLoad
            {
            case .formula:
                appState.failedWhileLoadingFormulae = true
            case .cask:
                appState.failedWhileLoadingCasks = true
            }

            return nil
        }
    }
}

private extension BrewPackagesTracker
{
    /// Load packages from disk, and convert them into ``BrewPackage``s
    func loadInstalledPackagesFromFolder(
        packageTypeToLoad: BrewPackage.PackageType
    ) async throws(PackageLoadingError) -> BrewPackages
    {
        do
        {
            /// This gets URLs to all package folders in a folder.
            /// `/opt/homebrew/Caskroom/microsoft-edge/`
            let urlsInParentFolder: [URL] = try getContentsOfFolder(targetFolder: packageTypeToLoad.parentFolder, options: [.skipsHiddenFiles])

            AppConstants.shared.logger.debug("Loaded contents of folder: \(urlsInParentFolder)")

            let namesOfPinnedPackages: Set<String>? = await getNamesOfPinnedPackagesDuringLoading()

            let namesOfTaggedPackages: Set<String>? = try? await getNamesOfTaggedPackages()

            let packageLoader: BrewPackages = await withTaskGroup(of: Result<BrewPackage, PackageLoadingError>.self)
            { taskGroup in
                for packageURL in urlsInParentFolder
                {
                    AppConstants.shared.logger.debug("Will add package at URL \(packageURL) to the package loading task group")

                    /// Check if the package folder is just a symlink - If so, it is just a renamed package and we don't have to parse it
                    // TODO: Create a more robust system for showing what the package was renamed to - see stash "Skeleton for more complete renamed package support"
                    guard packageURL.isSymlink() == false else
                    {
                        continue
                    }
                    
                    taskGroup.addTask
                    {
                        await self.loadInstalledPackage(
                            packageURL: packageURL,
                            namesOfPinnedPackages: namesOfPinnedPackages,
                            namesOfTaggedPackages: namesOfTaggedPackages
                        )
                    }

                    /*
                     guard taskGroup.addTaskUnlessCancelled(priority: .high, operation: {
                         await self.loadInstalledPackage(packageURL: packageURL)
                     })
                     else
                     {
                         AppConstants.shared.logger.warning("Package loading task group got cancelled")
                         break
                     }
                      */
                }

                var loadedPackages: BrewPackages = .init(minimumCapacity: urlsInParentFolder.count)
                for await loadedPackage in taskGroup
                {
                    loadedPackages.insert(loadedPackage)
                }

                let loggableLoadedPackages: String = loadedPackages.compactMap
                { rawResult in
                    switch rawResult
                    {
                    case .success(let success):
                        return success.name
                    case .failure(let failure):
                        return failure.errorDescription
                    }
                }.formatted(.list(type: .and))

                AppConstants.shared.logger.debug("Loaded \(packageTypeToLoad.description): \(loggableLoadedPackages)")

                return loadedPackages
            }

            let shouldStrictlyCheckForHomebrewErrors: Bool = UserDefaults.standard.bool(forKey: "strictlyCheckForHomebrewErrors")

            if shouldStrictlyCheckForHomebrewErrors
            {
                /// Check if the number of loaded packages, both successful and failed, matches the number of package URLs in the package container folder
                guard packageLoader.count == urlsInParentFolder.count
                else
                {
                    throw PackageLoadingError.numberOLoadedPackagesDosNotMatchNumberOfPackageFolders
                }
            }

            return packageLoader
        }
        catch let parentFolderReadingError
        {
            AppConstants.shared.logger.error("Couldn't get contents of folder \(packageTypeToLoad.parentFolder, privacy: .public)")

            throw .couldNotReadContentsOfParentFolder(failureReason: parentFolderReadingError.localizedDescription, folderURL: packageTypeToLoad.parentFolder)
        }
    }

    /// For a given `URL` to a package folder containing the various versions of the package, parse the package contained within
    /// - Parameter packageURL: `URL` to the package parent folder
    /// - Returns: A parsed package of the ``BrewPackage`` type
    func loadInstalledPackage(
        packageURL: URL,
        namesOfPinnedPackages: Set<String>?,
        namesOfTaggedPackages: Set<String>?
    ) async -> Result<BrewPackage, PackageLoadingError>
    {
        /// Get the name of the package - at this stage, it is the last path component
        let packageName: String = packageURL.packageNameFromURL()

        AppConstants.shared.logger.debug("Package name to load: \(packageName). Will check if this is a legit package")

        /// Check if we're not trying to read versions in the Cellar or Caskroom folder itself - this usually means Homebrew is broken
        guard packageName != "Cellar", packageName != "Caskroom"
        else
        {
            AppConstants.shared.logger.error("The last path component of the requested URL is the package container folder itself - perhaps a misconfigured package folder? Tried to load URL \(packageURL)")

            return .failure(.triedToThreatFolderContainingPackagesAsPackage(packageType: packageURL.packageType))
        }

        AppConstants.shared.logger.debug("Package \(packageName) is legit. Will try to process it")

        /// Let's try to parse the package now
        do
        {
            /// Gets URL to installed versions of a package provided as ``packageURL``
            /// `/opt/homebrew/Cellar/cmake/3.30.5`, `/opt/homebrew/Cellar/cmake/3.30.4`
            let versionURLs: [URL] = try getContentsOfFolder(targetFolder: packageURL, options: [.skipsHiddenFiles])

            guard !versionURLs.isEmpty
            else
            {
                AppConstants.shared.logger.error("Failed while loading package \(packageURL.packageNameFromURL()) because it has no versions installed")

                return .failure(.packageDoesNotHaveAnyVersionsInstalled(packageURL: packageURL))
            }

            /// Gets the name of the version, which at this stage is the last path component of the `versionURLs` URL
            let versionNamesForPackage: [String] = versionURLs.map
            { versionURL in
                versionURL.lastPathComponent
            }

            AppConstants.shared.logger.debug("Package \(packageURL.lastPathComponent) has these versions available: \(versionURLs.map { $0.absoluteString }.joined(separator: ", "))")

            do
            {
                AppConstants.shared.logger.debug("Will check if package \(packageName) was installed intentionally")

                let wasPackageInstalledIntentionally: Bool = try await packageURL.checkIfPackageWasInstalledIntentionally(versionURLs: versionURLs)

                AppConstants.shared.logger.debug("Package \(packageName) \(wasPackageInstalledIntentionally ? "was" : "was not") installed intentionally")

                /// Check whether the package is among the pinned packages
                /// If there was a failure during the loading of pinned packages, returns `false`
                let isPackagePinned: Bool = {
                    guard let namesOfPinnedPackages
                    else
                    {
                        return false
                    }

                    if namesOfPinnedPackages.contains(packageName)
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }()

                /// Check whether the package is among the tagged packages
                /// If there is a failure during the loading of tagged package, returns `false`
                let isPackageTagged: Bool = {
                    guard let namesOfTaggedPackages
                    else
                    {
                        return false
                    }

                    if namesOfTaggedPackages.contains(packageName)
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }()
                
                /// Find the latest installed version URL for Casks, and return the URL to the linked Formula directory for Formulae
                let urlToVersionUsedForDeterminingActualExecutableLocation: URL = {
                    switch packageURL.packageType
                    {
                    case .formula:
                        return packageURL
                    case .cask:
                        if let newestInstalledVersion = versionURLs.last
                        {
                            return newestInstalledVersion
                        }
                        else
                        {
                            return packageURL
                        }
                    }
                }()
                
                /// Resolve path to the actual executable for casks, and the path to the currently linked folder for formulae
                let finalExecutableURL: URL = await {
                    switch packageURL.packageType
                    {
                    case .formula:
                        AppConstants.shared.logger.debug("Package is formula, will use the Cellar URL (\(packageURL))")
                        return packageURL
                    case .cask:
                        
                        AppConstants.shared.logger.debug("Package is Cask, will try to discover the actual URL")
                        
                        let urlToActualExecutable: URL = await urlToVersionUsedForDeterminingActualExecutableLocation.getUrlToActualCaskExecutable()
                        
                        AppConstants.shared.logger.debug("Actual URL discovered: \(urlToActualExecutable)")
                        
                        return urlToActualExecutable
                    }
                }()

                let packageSize: Int64 = await {
                    switch packageURL.packageType
                    {
                    case .formula:
                        return packageURL.directorySize
                    case .cask:
                        guard let sizeOfActualApp: Int64 = await urlToVersionUsedForDeterminingActualExecutableLocation.getActualAppSize() else
                        {
                            return packageURL.directorySize
                        }
                        
                        return sizeOfActualApp
                    }
                }()
                
                let loadedPackage: Result<BrewPackage, PackageLoadingError> = .success(
                    .init(
                        name: packageName,
                        type: packageURL.packageType,
                        isTagged: isPackageTagged,
                        isPinned: isPackagePinned,
                        installedOn: packageURL.creationDate,
                        versions: versionNamesForPackage,
                        url: finalExecutableURL,
                        installedIntentionally: wasPackageInstalledIntentionally,
                        sizeInBytes: packageSize,
                        downloadCount: nil
                    )
                )

                return loadedPackage
            }
            catch let intentionalInstallationDiscoveryError
            {
                throw PackageLoadingError.failedWhileTryingToDetermineIntentionalInstallation(folderURL: packageURL, associatedIntentionalDiscoveryError: intentionalInstallationDiscoveryError)
            }
        }
        catch let loadingError
        {
            AppConstants.shared.logger.error("Failed while loading package \(packageURL.lastPathComponent, privacy: .public): \(loadingError.localizedDescription)")

            return .failure(.failedWhileReadingContentsOfPackageFolder(folderURL: packageURL, reportedError: loadingError.localizedDescription))
        }
    }

    private func getNamesOfPinnedPackagesDuringLoading() async -> Set<String>?
    {
        // MARK: - Getting pinned packages

        guard let pinnedPackagesPath: URL = AppConstants.shared.pinnedPackagesPath
        else
        {
            return nil
        }

        return await self.getNamesOfPinnedPackages(atPinnedPackagesPath: pinnedPackagesPath)
    }
}

private extension URL
{
    /// Resolve the app's symlink and get the URL of the actual `.app` in the `Applications` folder
    func getUrlToActualCaskExecutable() async -> URL
    {
        do
        {
            /// Get the contents of the version's folder
            let contentsOfVersionFolder: [URL] = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [.isSymbolicLinkKey])
            
            AppConstants.shared.logger.info("Discovered these versions for determining actual app size: \(contentsOfVersionFolder)")

            /// Filter out the symlinks, and do your best to approximate which symlink is valid (there should be only one, anyway). If something breaks, be conservative and say there are no symlinks
            guard let symlinkUrl: URL = contentsOfVersionFolder.filter({ $0.isSymlink() ?? false }).first
            else
            {
                AppConstants.shared.logger.error("Could read the contents of the version's folder at \(self), but there was nothing")

                return self
            }

            AppConstants.shared.logger.info("Will use this symlink URL for determining app size: \(symlinkUrl)")
            
            /// Resolve the symlink to the location of the actual app
            let resolvedSymlinkUrl: URL = symlinkUrl.resolvingSymlinksInPath()
            
            AppConstants.shared.logger.info("Symlink for determining app size resolved to \(resolvedSymlinkUrl)")

            /// Make sure the resolved symlink is not the original URL itself
            guard resolvedSymlinkUrl != self
            else
            {
                AppConstants.shared.logger.info("The resolved symlink for URL \(self) was the same as the original URL")

                return self
            }

            /// Return the size of the app bundle
            return resolvedSymlinkUrl
            
        }
        catch let directoryContentsDiscoveryError
        {
            AppConstants.shared.logger.error("Couldn't read the contents of Cask's version folder at \(self): \(directoryContentsDiscoveryError.localizedDescription). Will use the size of the symlink folder")

            return self
        }
    }
    
    /// Get the actual size of the installed app by resolving a symlink inside a version's folder and loading the size of the app from the `Applications` directory
    func getActualAppSize() async -> Int64?
    {
        return await getUrlToActualCaskExecutable().directorySize
    }
}

private extension FileManager
{
    func sizeOfFile(at url: URL) -> Int64?
    {
        guard let attrs = try? attributesOfItem(atPath: url.path)
        else
        {
            return nil
        }

        return attrs[.size] as? Int64
    }
}
