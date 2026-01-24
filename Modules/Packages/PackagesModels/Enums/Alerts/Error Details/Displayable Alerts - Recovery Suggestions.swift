//
//  Displayable Alerts - Recovery Suggestions.swift
//  Cork
//
//  Created by David Bureš on 31.05.2024.
//

import Foundation

public extension DisplayableAlert
{
    /// Message in the alert
    var recoverySuggestion: String?
    {
        switch self
        {
        case .generic(let customMessage):
            return customMessage
        case .couldNotGetContentsOfPackageFolder(let localizedError):
            return String(localized: "alert.could-not-get-contents-of-package-folder.message-\(localizedError)")
        case .couldNotLoadAnyPackages:
            return String(localized: "alert.restart-or-reinstall")
        case .couldNotLoadCertainPackage(_, _, let failureReason):
            return failureReason
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
            return String(localized: "alert.unable-to-uninstall-dependency.message-\(offendingDependencyProhibitingUninstallation)-\(packageThatTheUserIsTryingToUninstall.getPackageName(withPrecision: .precise))")
        case .metadataFolderDoesNotExist:
            return String(localized: "alert.metadata-folder-does-not-exist.message")
        case .couldNotCreateCorkMetadataDirectory:
            return String(localized: "alert.could-not-create-metadata-directory-or-folder.message")
        case .couldNotCreateCorkMetadataFile:
            return String(localized: "alert.could-not-create-metadata-directory-or-folder.message")
        case .installedPackageHasNoVersions:
            return String(localized: "alert.package-corrupted.message")
        case .installedPackageIsNotAFolder(let itemName, _):
            return String(localized: "alert.tried-to-load-package-that-is-not-a-folder.message-\(itemName)")
        case .homePathNotSet:
            return String(localized: "alert.home-not-set.message")
        case .numberOfLoadedPackagesDoesNotMatchNumberOfPackageFolders:
            return nil
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
        case .fatalPackageUninstallationError(_, let errorDetails):
            return errorDetails
        case .couldNotSynchronizePackages(let error):
            return error
        case .couldNotGetWorkingDirectory:
            return String(localized: "message.try-again-or-restart")
        case .couldNotDumpBrewfile(let error):
            return String(localized: "message.try-again-or-restart-\(error)")
        case .couldNotReadBrewfile(let error):
            return error
        case .couldNotGetBrewfileLocation:
            return String(localized: "alert.could-not-get-brewfile-location.message")
        case .couldNotImportBrewfile:
            return String(localized: "alert.could-not-import-brewfile.message")
        case .malformedBrewfile:
            return String(localized: "alert.malformed-brewfile.message")
        case .tapLoadingFailedDueToTapParentLocation(let localizedDescription):
            return localizedDescription
        case .tapLoadingFailedDueToTapItself(let localizedDescription):
            return localizedDescription
        case .triedToThreatFolderContainingPackagesAsPackage(let packageType):
            return BrewPackage.PackageLoadingError.triedToThreatFolderContainingPackagesAsPackage(packageType: packageType).localizedDescription
        case .couldNotDeleteCachedDownloads(let associatedError):
            return associatedError
        }
    }
}
