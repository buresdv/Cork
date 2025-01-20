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
    @EnvironmentObject var appState: AppState
    
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
            inspectErrorButton(errorText: failureReason)
            
        case .failedWhileReadingContentsOfPackageFolder(let folderURL, let reportedError):
            inspectErrorButton(errorText: reportedError)
            
        case .failedWhileTryingToDetermineIntentionalInstallation(let folderURL, let associatedIntentionalDiscoveryError):
            inspectErrorButton(errorText: associatedIntentionalDiscoveryError.localizedDescription)
            
        case .packageDoesNotHaveAnyVersionsInstalled(let packageURL):
            showReinstallSheetButton(packageNameToReinstall: packageURL.packageNameFromURL())
            
        case .packageIsNotAFolder(let string, let packageURL):
            inspectErrorButton(errorText: string)
            
        case .numberOLoadedPackagesDosNotMatchNumberOfPackageFolders:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func inspectErrorButton(errorText: String) -> some View
    {
        Button {
            AppConstants.shared.logger.info("Clicked Inspect")
            appState.showSheet(ofType: .corruptedPackageInspectError(errorText: errorText))
        } label: {
            Text("action.inspect-error")
        }

    }
    
    @ViewBuilder
    func showReinstallSheetButton(packageNameToReinstall: String) -> some View
    {
        Button
        {
            appState.showSheet(ofType: .corruptedPackageFix(corruptedPackage: .init(name: packageNameToReinstall)))
        } label: {
            Text("action.reinstall-package")
        }
    }
}
