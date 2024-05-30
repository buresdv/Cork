//
//  Displayable Alerts - Descriptions.swift
//  Cork
//
//  Created by David Bureš on 31.05.2024.
//

import Foundation

extension DisplayableAlert
{
    /// The bold text at the top of the error
    var errorDescription: String?
    {
        switch self
        {
        case .couldNotLoadAnyPackages(let error):
            return "alert.fatal.could-not-load-any-packages-\(error.localizedDescription).title"
        case .couldNotLoadCertainPackage(let offendingPackage):
               return "alert.fatal-\(offendingPackage)-prevented-loading.title"
        case .licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly:
            return "alert.fatal.license-checking.could-not-encode-authorization-complex.title"
        case .customBrewExcutableGotDeleted:
            return "alert.fatal.custom-brew-executable-deleted.title"
        case .couldNotFindPackageUUIDInList:
            return "alert.could-not-find-package-uuid-in-list"
        case .uninstallationNotPossibleDueToDependency(let packageThatTheUserIsTryingToUninstall):
            return "alert.unable-to-uninstall-\(packageThatTheUserIsTryingToUninstall.name).title"
        case .couldNotApplyTaggedStateToPackages:
            return "alert.could-not-apply-tags.title"
        case .couldNotClearMetadata:
            return "alert.could-not-clear-metadata.title"
        case .metadataFolderDoesNotExist:
            return "alert.metadata-folder-does-not-exist.title"
        case .couldNotCreateCorkMetadataDirectory:
            return "alert.could-not-create-metadata-directory.title"
        case .couldNotCreateCorkMetadataFile:
            return "alert.could-not-create-metadata-file.title"
        case .installedPackageHasNoVersions(let corruptedPackageName):
            return "alert.package-corrupted.title-\(corruptedPackageName)"
        case .homePathNotSet:
            return "alert.home-not-set.title"
        case .couldNotObtainNotificationPermissions:
            return "alert.notifications-error-while-obtaining-permissions.title"
        case .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(let offendingTapProhibitingRemovalOfTap):
            return "sidebar.section.added-taps.remove.title-\(offendingTapProhibitingRemovalOfTap)"
        case .couldNotParseTopPackages:
            return "alert.notifications-error-while-parsing-top-packages.title"
        case .receivedInvalidResponseFromBrew:
            return "alert.notifications-error-while-getting-top-packages.title"
        case .topPackageArrayFilterCouldNotRetrieveAnyPackages:
            return "alert.top-package-retrieval-function-turned-up-empty.title"
        case .couldNotAssociateAnyPackageWithProvidedPackageUUID:
            return "alert.could-not-associate-any-package-in-tracker-with-provided-uuid.title"
        case .couldNotFindPackageInParentDirectory:
            return "alert.could-not-find-package-in-parent-directory.title"
        case .fatalPackageInstallationError(_):
            return "alert.fatal-installation.error"
        case .couldNotSynchronizePackages:
            return "alert.fatal.could-not-synchronize-packages.title"
        case .couldNotGetWorkingDirectory:
            return "alert.could-not-get-brewfile-working-directory.title"
        case .couldNotDumpBrewfile(_):
            return "alert.could-not-dump-brewfile.title"
        case .couldNotReadBrewfile:
            return "alert.could-not-read-brewfile.title"
        case .couldNotGetBrewfileLocation:
            return "alert.could-not-get-brewfile-location.title"
        case .couldNotImportBrewfile:
            return "alert.could-not-import-brewfile.title"
        case .malformedBrewfile:
            return "alert.malformed-brewfile.title"
        }
    }
}
