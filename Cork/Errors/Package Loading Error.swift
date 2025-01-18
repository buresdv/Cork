//
//  Package Loading Error.swift
//  Cork
//
//  Created by David Bureš on 10.11.2024.
//

import Foundation

/// Error representing failures while loading
enum PackageLoadingError: LocalizedError, Hashable, Identifiable
{
    /// When attempting to get the list of raw URLs from the folder containing the packages, the function for loading packages returned nil, therefore, an error occured
    
    /// Failed while loading any package at all
    case failedWhileLoadingPackages(failureReason: String?)
    
    /// The `Cellar` and `Caskroom` folder itself couldn't be loaded
    case couldNotReadContentsOfParentFolder(failureReason: String, folderURL: URL)
    
    /// Couldn't read contents of the folder that contain package versions
    case failedWhileLoadingCertainPackage(failureReason: String, packageURL: URL)
    
    /// The package root folder exists, but the package itself doesn't have any versions
    case packageDoesNotHaveAnyVersionsInstalled(packageURL: URL)
    
    /// A folder that should have contained the package is not actually a folder
    case packageIsNotAFolder(String, packageURL: URL)
    
    /// The number of loaded packages does not match the number of package parent folders
    case numberOLoadedPackagesDosNotMatchNumberOfPackageFolders

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotReadContentsOfParentFolder(let failureReason, _):
            return String(localized: "error.package-loading.could-not-read-contents-of-parent-folder.\(failureReason)")
        case .failedWhileLoadingPackages(let failureReason):
            if let failureReason
            {
                return String(localized: "error.package-loading.could-not-load-packages.\(failureReason)")
            }
            else
            {
                return String(localized: "error.package-loading.could-not-load-packages")
            }
        case .failedWhileLoadingCertainPackage(let failureReason, let packageURL):
            return String(localized: "error.package-loading.could-not-load-\(packageURL.packageNameFromURL())-at-\(packageURL.absoluteString)-because-\(failureReason)", comment: "Couldn't load package (package name) at (package URL) because (failure reason)")
        case .packageDoesNotHaveAnyVersionsInstalled(let packageURL):
            return String(localized: "error.package-loading.\(packageURL.packageNameFromURL())-does-not-have-any-versions-installed")
        case .packageIsNotAFolder(let string, _):
            return String(localized: "error.package-loading.\(string)-not-a-folder", comment: "Package folder in this context means a folder that encloses package versions. Every package has its own folder, and this error occurs when the provided URL does not point to a folder that encloses package versions")
        case .numberOLoadedPackagesDosNotMatchNumberOfPackageFolders:
            return String(localized: "error.package-loading.number-of-loaded-poackages-does-not-match-number-of-package-folders", comment: "This error occurs when there's a mismatch between the number of loaded packages, and the number of package folders in the package folders")
        }
    }
    
    var id: UUID
    {
        return UUID.init()
    }
}
