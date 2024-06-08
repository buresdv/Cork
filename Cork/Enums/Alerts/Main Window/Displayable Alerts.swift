//
//  Fatal Error Types.swift
//  Cork
//
//  Created by David Bureš on 22.03.2023.
//

import Foundation

enum DisplayableAlert: LocalizedError
{
    case couldNotLoadAnyPackages(Error), couldNotLoadCertainPackage(String, URL)
    case licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly
    case customBrewExcutableGotDeleted
    case couldNotFindPackageUUIDInList
    case uninstallationNotPossibleDueToDependency(packageThatTheUserIsTryingToUninstall: BrewPackage, offendingDependencyProhibitingUninstallation: String), couldNotApplyTaggedStateToPackages, couldNotClearMetadata, metadataFolderDoesNotExist, couldNotCreateCorkMetadataDirectory, couldNotCreateCorkMetadataFile, installedPackageHasNoVersions(corruptedPackageName: String), installedPackageIsNotAFolder(itemName: String, itemURL: URL), homePathNotSet
    case couldNotObtainNotificationPermissions
    case couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(offendingTapProhibitingRemovalOfTap: String)
    case couldNotParseTopPackages
    case receivedInvalidResponseFromBrew
    case topPackageArrayFilterCouldNotRetrieveAnyPackages
    case couldNotAssociateAnyPackageWithProvidedPackageUUID
    case couldNotFindPackageInParentDirectory
    case fatalPackageInstallationError(String)
    case couldNotSynchronizePackages

    // MARK: - Brewfile exporting/importing
    case couldNotGetWorkingDirectory, couldNotDumpBrewfile(error: String), couldNotReadBrewfile
    case couldNotGetBrewfileLocation, couldNotImportBrewfile, malformedBrewfile
}
