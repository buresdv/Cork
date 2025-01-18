//
//  Broken Package List Row.swift
//  Cork
//
//  Created by David Bureš - P on 18.01.2025.
//

import SwiftUI
import CorkShared

struct BrokenPackageListRow: View
{
    
    let error: PackageLoadingError
    
    var body: some View
    {
        HStack(alignment: .center) {
            Text(error.localizedDescription)
            
            Spacer()
            
            fixPackageButton
        }
    }
    
    @ViewBuilder
    var fixPackageButton: some View
    {
        switch self.error
        {
        case .triedToThreatFolderContainingPackagesAsPackage(let packageType):
            ReinstallHomebrewButton()

        case .couldNotReadContentsOfParentFolder(let failureReason, let folderURL):
            inspectErrorButton
        case .failedWhileReadingContentsOfPackageFolder(let folderURL, let reportedError):
            inspectErrorButton
        case .failedWhileTryingToDetermineIntentionalInstallation(let folderURL, let associatedIntentionalDiscoveryError):
            inspectErrorButton
        case .packageDoesNotHaveAnyVersionsInstalled(let packageURL):
            inspectErrorButton
        case .packageIsNotAFolder(let string, let packageURL):
            inspectErrorButton
        case .numberOLoadedPackagesDosNotMatchNumberOfPackageFolders:
            inspectErrorButton
        }
    }
    
    @ViewBuilder
    var inspectErrorButton: some View
    {
        Button {
            AppConstants.shared.logger.info("Clicked Inspect")
        } label: {
            Text("action.inspect-error")
        }

    }
}
