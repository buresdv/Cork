//
//  Displayable Alerts - Recovery Suggestions.swift
//  Cork
//
//  Created by David Bureš on 31.05.2024.
//

import Foundation

extension DisplayableAlert
{
    var recoverySuggestion: String?
    {
        switch self
        {
        case .couldNotLoadAnyPackages:
            return String(localized: "alert.restart-or-reinstall")
        case .couldNotLoadCertainPackage(let offendingPackageName, let offendingPackageURL, let failureReason):
                return failureReason.stringValue()
        case .licenseCheckingFailedDueToAuthorizationComplexNotBeingEncodedProperly:
            return String(localized: "alert.fatal.license-checking.could-not-encode-authorization-complex.message")
        case .licenseCheckingFailedDueToNoInternet:
            return String(localized: "alert.fatal.license-checking.no-internet.message")
        case .licenseCheckingFailedDueToTimeout:
            return String(localized: "alert.fatal.license-checking.timed-out.message")
        case .licenseCheckingFailedForOtherReason(let localizedError):
            return localizedError
        case .customBrewExcutableGotDeleted:
            return nil
        case .couldNotFindPackageUUIDInList:
            return nil
        case .uninstallationNotPossibleDueToDependency(let packageThatTheUserIsTryingToUninstall, let offendingDependencyProhibitingUninstallation):
            return String(localized: "alert.unable-to-uninstall-dependency.message-\(offendingDependencyProhibitingUninstallation)-\(packageThatTheUserIsTryingToUninstall.name)")
        case .couldNotApplyTaggedStateToPackages:
            return String(localized: "alert.could-not-apply-tags.message")
        case .couldNotClearMetadata:
            return String(localized: "alert.could-not-clear-metadata.message")
        case .metadataFolderDoesNotExist:
            return String(localized: "alert.metadata-folder-does-not-exist.message")
        case .couldNotCreateCorkMetadataDirectory:
            return String(localized: "alert.could-not-create-metadata-directory-or-folder.message")
        case .couldNotCreateCorkMetadataFile:
            return String(localized: "alert.could-not-create-metadata-directory-or-folder.message")
        case .installedPackageHasNoVersions:
            return String(localized: "alert.package-corrupted.message")
        case .installedPackageIsNotAFolder(itemName: let itemName, itemURL: let itemURL):
            return String(localized: "alert.tried-to-load-package-that-is-not-a-folder.message-\(itemName)")
        case .homePathNotSet:
            return String(localized: "alert.home-not-set.message")
        case .couldNotObtainNotificationPermissions:
            return String(localized: "alert.notifications-error-while-obtaining-permissions.message")
        case .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(let offendingTapProhibitingRemovalOfTap):
            return String(localized: "alert.notification-could-not-remove-tap-due-to-packages-from-it-still-being-installed.message-\(offendingTapProhibitingRemovalOfTap)")
        case .couldNotParseTopPackages(let errorMessage):
            return errorMessage
        case .receivedInvalidResponseFromBrew:
            return String(localized: "alert.notifications-error-while-getting-top-package.message")
        case .topPackageArrayFilterCouldNotRetrieveAnyPackages:
            return String(localized: "alert.top-package-retrieval-function-turned-up-empty.message")
        case .couldNotAssociateAnyPackageWithProvidedPackageUUID:
            return String(localized: "alert.could-not-associate-any-package-in-tracker-with-provided-uuid.message")
        case .couldNotFindPackageInParentDirectory:
            return String(localized: "message.try-again-or-restart")
        case .fatalPackageInstallationError(let errorDetails):
            return errorDetails
        case .couldNotSynchronizePackages:
            return nil
        case .couldNotGetWorkingDirectory:
            return String(localized: "message.try-again-or-restart")
        case .couldNotDumpBrewfile(let error):
            return String(localized: "message.try-again-or-restart-\(error)")
        case .couldNotReadBrewfile:
            return String(localized: "message.try-again-or-restart")
        case .couldNotGetBrewfileLocation:
            return String(localized: "alert.could-not-get-brewfile-location.message")
        case .couldNotImportBrewfile:
            return String(localized: "alert.could-not-import-brewfile.message")
        case .malformedBrewfile:
            return String(localized: "alert.malformed-brewfile.message")
        }
    }
}
