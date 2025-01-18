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
        if !brewData.unsuccessfullyLoadedFormulaeErrors.isEmpty
        {
            GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.terminal.badge.xmark")
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("start-page.unloaded-formulae.count-\(brewData.unsuccessfullyLoadedFormulaeErrors.count)")
                    
                    DisclosureGroup(isExpanded: $isFormulaeGroupExpanded)
                    {
                        List(brewData.unsuccessfullyLoadedFormulaeErrors)
                        { error in
                            BrokenPackageListRow(error: error)
                        }
                        .listStyle(.bordered)
                    } label: {
                        Text(isFormulaeGroupExpanded ? "action.hide" : "action.show")
                            .font(.subheadline)
                    }
                    .disclosureGroupStyle(NoPadding())
                }
            }
        }
        
        if !brewData.unsuccessfullyLoadedCasksErrors.isEmpty
        {
            GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.macwindow.badge.xmark")
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("start-page.unloaded-casks.count-\(brewData.unsuccessfullyLoadedCasksErrors.count)")
                    
                    DisclosureGroup(isExpanded: $isCasksGroupExpanded)
                    {
                        List(brewData.unsuccessfullyLoadedCasksErrors)
                        { error in
                            BrokenPackageListRow(error: error)
                        }
                        .listStyle(.bordered)
                    } label: {
                        Text(isCasksGroupExpanded ? "action.hide" : "action.show")
                            .font(.subheadline)
                    }
                    .disclosureGroupStyle(NoPadding())
                }
            }
        }
    }
}
