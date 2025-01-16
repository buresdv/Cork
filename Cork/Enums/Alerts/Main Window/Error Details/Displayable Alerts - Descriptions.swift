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
        case .couldNotGetContentsOfPackageFolder:
            return String(localized: "alert.could-not-get-contents-of-package-folder.title")
        case .couldNotLoadAnyPackages(let error):
            return String(localized: "alert.fatal.could-not-load-any-packages-\(error.localizedDescription).title")
        case .couldNotLoadCertainPackage(let offendingPackage, _, _):
            return String(localized: "alert.fatal-\(offendingPackage)-prevented-loading.title")
        case .licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly:
            return String(localized: "alert.fatal.license-checking.could-not-encode-authorization-complex.title")
        case .licenseCheckingFailedDueToNoInternet:
            return String(localized: "alert.fatal.license-checking.no-internet.title")
        case .licenseCheckingFailedDueToTimeout:
            return String(localized: "alert.fatal.license-checking.timed-out.title")
        case .licenseCheckingFailedForOtherReason:
            return String(localized: "alert.fatal.license-checking.unimplemented-error.title")
        case .customBrewExcutableGotDeleted:
            return String(localized: "alert.fatal.custom-brew-executable-deleted.title")
        case .couldNotFindPackageUUIDInList:
            return String(localized: "alert.could-not-find-package-uuid-in-list")
        case .uninstallationNotPossibleDueToDependency(let packageThatTheUserIsTryingToUninstall, _):
            return String(localized: "alert.unable-to-uninstall-\(packageThatTheUserIsTryingToUninstall.name).title")
        case .couldNotApplyTaggedStateToPackages:
            return String(localized: "alert.could-not-apply-tags.title")
        case .couldNotClearMetadata:
            return String(localized: "alert.could-not-clear-metadata.title")
        case .metadataFolderDoesNotExist:
            return String(localized: "alert.metadata-folder-does-not-exist.title")
        case .couldNotCreateCorkMetadataDirectory:
            return String(localized: "alert.could-not-create-metadata-directory.title")
        case .couldNotCreateCorkMetadataFile:
            return String(localized: "alert.could-not-create-metadata-file.title")
        case .installedPackageHasNoVersions(let corruptedPackageName):
            return String(localized: "alert.package-corrupted.title-\(corruptedPackageName)")
        case .installedPackageIsNotAFolder(itemName: let itemName, itemURL: _):
            return String(localized: "alert.tried-to-load-package-that-is-not-a-folder.title-\(itemName)")
        case .homePathNotSet:
            return String(localized: "alert.home-not-set.title")
        case .numberOfLoadedPackagesDoesNotMatchNumberOfPackageFolders:
            return PackageLoadingError.numberOLoadedPackagesDosNotMatchNumberOfPackageFolders.localizedDescription
        case .couldNotObtainNotificationPermissions:
            return String(localized: "alert.notifications-error-while-obtaining-permissions.title")
        case .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(let offendingTapProhibitingRemovalOfTap):
            return String(localized: "sidebar.section.added-taps.remove.title-\(offendingTapProhibitingRemovalOfTap)")
        case .couldNotParseTopPackages:
            return String(localized: "alert.notifications-error-while-parsing-top-packages.title")
        case .receivedInvalidResponseFromBrew:
            return String(localized: "alert.notifications-error-while-getting-top-packages.title")
        case .topPackageArrayFilterCouldNotRetrieveAnyPackages:
            return String(localized: "alert.top-package-retrieval-function-turned-up-empty.title")
        case .couldNotAssociateAnyPackageWithProvidedPackageUUID:
            return String(localized: "alert.could-not-associate-any-package-in-tracker-with-provided-uuid.title")
        case .couldNotFindPackageInParentDirectory:
            return String(localized: "alert.could-not-find-package-in-parent-directory.title")
        case .fatalPackageInstallationError:
            return String(localized: "alert.fatal-installation.error")
        case .fatalPackageUninstallationError(let packageName, _):
            return String(localized: "alert.unable-to-uninstall-\(packageName).title")
        case .couldNotSynchronizePackages:
            return String(localized: "alert.fatal.could-not-synchronize-packages.title")
        case .couldNotGetWorkingDirectory:
            return String(localized: "alert.could-not-get-brewfile-working-directory.title")
        case .couldNotDumpBrewfile:
            return String(localized: "alert.could-not-dump-brewfile.title")
        case .couldNotReadBrewfile:
            return String(localized: "alert.could-not-read-brewfile.title")
        case .couldNotGetBrewfileLocation:
            return String(localized: "alert.could-not-get-brewfile-location.title")
        case .couldNotImportBrewfile:
            return String(localized: "alert.could-not-import-brewfile.title")
        case .malformedBrewfile:
            return String(localized: "alert.malformed-brewfile.title")
        case .tapLoadingFailedDueToTapParentLocation:
            return String(localized: "alert.tap-loading-failed.tap-parent.title")
        case .tapLoadingFailedDueToTapItself:
            return String(localized: "alert.tap-loading-failed.tap-itself.title")
        }
    }
}
