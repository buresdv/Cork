//
//  Tag Untag Button.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2025.
//

import SwiftUI
import CorkShared

struct TagUntagButton: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage
    
    let package: BrewPackage
    
    var body: some View {
        Button
        {
            changeTaggedStatus()
        } label: {
            Label(package.isTagged ? "sidebar.section.all.contextmenu.untag-\(package.name)" : "sidebar.section.all.contextmenu.tag-\(package.name)", systemImage: package.isTagged ? "tag.slash" : "tag")
        }
    }
    
    func changeTaggedStatus()
    {
        AppConstants.shared.logger.info("Will change tagged status of \(package.name). Current state of the tagged package tracker: \(appState.taggedPackageNames)")
        
        brewData.updatePackageInPlace(package)
        { package in
            package.changeTaggedStatus()
        }
        
        if package.isTagged
        {
            AppConstants.shared.logger.info("Tagged package tracker DOES contain \(package.name). Will remove")
            appState.taggedPackageNames.remove(package.name)
        }
        else
        {
            AppConstants.shared.logger.info("Tagged package tracker does NOT contain \(package.name). Will insert")
            appState.taggedPackageNames.insert(package.name)
        }
        
    }
}
