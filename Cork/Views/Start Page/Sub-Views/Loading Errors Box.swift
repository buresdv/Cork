//
//  Loading Errors Box.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import SwiftUI

struct LoadingErrorsBox: View
{
    
    @EnvironmentObject var brewData: BrewDataStorage
    
    @State private var isFormulaeGroupExpanded: Bool = false
    @State private var isCasksGroupExpanded: Bool = false
    
    var body: some View
    {
        GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.apple.terminal.badge.xmark")
        {
            Text("start-page.unloaded-formulae.count-\(brewData.unsuccessfullyLoadedFormulaeErrors.count)")
            
            DisclosureGroup(isFormulaeGroupExpanded ? "action.hide" : "action.show")
            {
                List(brewData.unsuccessfullyLoadedFormulaeErrors)
                { error in
                    Text(error.localizedDescription)
                }
            }
        }
        
        GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.macwindow.badge.xmark") {
            Text("start-page.unloaded-casks.count-\(brewData.unsuccessfullyLoadedCasksErrors.count)")
            
            DisclosureGroup(isCasksGroupExpanded ? "action.hide" : "action.show")
            {
                List(brewData.unsuccessfullyLoadedCasksErrors)
                { error in
                    Text(error.localizedDescription)
                }
            }
        }
    }
}
