//
//  Fatal Error Types.swift
//  Cork
//
//  Created by David Bureš on 22.03.2023.
//

import Foundation

enum FatalAlertType
{
    case couldNotLoadAnyPackages(Error), couldNotLoadCertainPackage(String)
    case licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly
    case customBrewExcutableGotDeleted
    case uninstallationNotPossibleDueToDependency(packageThatTheUserIsTryingToUninstall: BrewPackage), couldNotApplyTaggedStateToPackages, couldNotClearMetadata, metadataFolderDoesNotExist, couldNotCreateCorkMetadataDirectory, couldNotCreateCorkMetadataFile, installedPackageHasNoVersions(corruptedPackageName: String), homePathNotSet
    case couldNotObtainNotificationPermissions
	case couldNotRemoveTapDueToPackagesFromItStillBeingInstalled
    case couldNotParseTopPackages
    case receivedInvalidResponseFromBrew
    case topPackageArrayFilterCouldNotRetrieveAnyPackages
    case couldNotAssociateAnyPackageWithProvidedPackageUUID
    case couldNotFindPackageInParentDirectory
    case fatalPackageInstallationError(String)
    case couldNotSynchronizePackages
    
    //MARK: - Brewfile exporting/importing
    case couldNotGetWorkingDirectory, couldNotDumpBrewfile(error: String), couldNotReadBrewfile
    case couldNotGetBrewfileLocation, couldNotImportBrewfile, malformedBrewfile
}
