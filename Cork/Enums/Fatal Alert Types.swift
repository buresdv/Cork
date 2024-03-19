//
//  Fatal Error Types.swift
//  Cork
//
//  Created by David Bureš on 22.03.2023.
//

import Foundation

enum FatalAlertType
{
    case licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly
    case customBrewExcutableGotDeleted
    case uninstallationNotPossibleDueToDependency, couldNotApplyTaggedStateToPackages, couldNotClearMetadata, metadataFolderDoesNotExist, couldNotCreateCorkMetadataDirectory, couldNotCreateCorkMetadataFile, installedPackageHasNoVersions, homePathNotSet
    case couldNotObtainNotificationPermissions
	case couldNotRemoveTapDueToPackagesFromItStillBeingInstalled
    case couldNotParseTopPackages
    case receivedInvalidResponseFromBrew
    case topPackageArrayFilterCouldNotRetrieveAnyPackages
    case couldNotAssociateAnyPackageWithProvidedPackageUUID
    case couldNotFindPackageInParentDirectory
    case fatalPackageInstallationError
    
    //MARK: - Brewfile exporting/importing
    case couldNotGetWorkingDirectory, couldNotDumpBrewfile, couldNotReadBrewfile
    case couldNotGetBrewfileLocation, couldNotImportBrewfile, malformedBrewfile
}
