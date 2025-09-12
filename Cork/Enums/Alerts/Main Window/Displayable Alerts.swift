//
//  Fatal Error Types.swift
//  Cork
//
//  Created by David Bureš on 22.03.2023.
//

import Foundation
import SwiftUI

enum DisplayableAlert: LocalizedError
{
    case couldNotGetContentsOfPackageFolder(String), couldNotLoadAnyPackages(LocalizedError), couldNotLoadCertainPackage(String, URL, failureReason: String)
    case licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly, licenseCheckingFailedDueToNoInternet, licenseCheckingFailedDueToTimeout, licenseCheckingFailedForOtherReason(localizedDescription: String)
    case tapLoadingFailedDueToTapParentLocation(localizedDescription: String), tapLoadingFailedDueToTapItself(localizedDescription: String)
    case customBrewExcutableGotDeleted
    case couldNotFindPackageUUIDInList
    case uninstallationNotPossibleDueToDependency(packageThatTheUserIsTryingToUninstall: BrewPackage, offendingDependencyProhibitingUninstallation: String), metadataFolderDoesNotExist, couldNotCreateCorkMetadataDirectory, couldNotCreateCorkMetadataFile, installedPackageHasNoVersions(corruptedPackageName: String), installedPackageIsNotAFolder(itemName: String, itemURL: URL), homePathNotSet, numberOfLoadedPackagesDoesNotMatchNumberOfPackageFolders, triedToThreatFolderContainingPackagesAsPackage(packageType: PackageType)
    case couldNotObtainNotificationPermissions
    case couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(offendingTapProhibitingRemovalOfTap: String)
    case couldNotParseTopPackages(error: String)
    case receivedInvalidResponseFromBrew
    case topPackageArrayFilterCouldNotRetrieveAnyPackages
    case couldNotAssociateAnyPackageWithProvidedPackageUUID
    case couldNotFindPackageInParentDirectory
    case fatalPackageInstallationError(String)
    case fatalPackageUninstallationError(packageName: String, errorDetails: String)
    case couldNotSynchronizePackages(error: String)
    
    case couldNotDeleteCachedDownloads(error: String)

    // MARK: - Brewfile exporting/importing

    case couldNotGetWorkingDirectory, couldNotDumpBrewfile(error: String), couldNotReadBrewfile(error: String)
    case couldNotGetBrewfileLocation, couldNotImportBrewfile, malformedBrewfile
}
