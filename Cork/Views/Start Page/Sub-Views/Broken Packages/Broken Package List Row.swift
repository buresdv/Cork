//
//  Broken Package List Row.swift
//  Cork
//
//  Created by David Bureš - P on 18.01.2025.
//

import SwiftUI
import CorkShared
import CorkModels

struct BrokenPackageListRow: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    @Environment(AppState.self) var appState: AppState
    
    let error: BrewPackage.PackageLoadingError
    
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
        case .triedToThreatFolderContainingPackagesAsPackage:
            ReinstallHomebrewButton()

        case .couldNotReadContentsOfParentFolder(let failureReason, _):
            inspectErrorButton(errorText: failureReason)
            
        case .failedWhileReadingContentsOfPackageFolder(_, let reportedError):
            inspectErrorButton(errorText: reportedError)
            
        case .failedWhileTryingToDetermineIntentionalInstallation(_, let associatedIntentionalDiscoveryError):
            inspectErrorButton(errorText: associatedIntentionalDiscoveryError.localizedDescription)
            
        case .packageDoesNotHaveAnyVersionsInstalled(let packageURL):
            showReinstallSheetButton(packageNameToReinstall: packageURL.packageNameFromURL())
            
        case .packageIsNotAFolder(let string, _):
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
            
            openWindow(id: .errorInspectorWindowID, value: errorText)
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
