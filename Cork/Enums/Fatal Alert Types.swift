//
//  Fatal Error Types.swift
//  Cork
//
//  Created by David Bureš on 22.03.2023.
//

import Foundation

enum FatalAlertType
{
    case uninstallationNotPossibleDueToDependency, couldNotApplyTaggedStateToPackages, couldNotClearMetadata, metadataFolderDoesNotExist, couldNotCreateCorkMetadataDirectory, couldNotCreateCorkMetadataFile, installedPackageHasNoVersions, homePathNotSet
}
