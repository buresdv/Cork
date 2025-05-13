//
//  Loading Errors Box.swift
//  Cork
//
//  Created by David Bureš - P on 16.01.2025.
//

import SwiftUI

struct LoadingErrorsBox: View
{
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @State private var isFormulaeGroupExpanded: Bool = false
    @State private var isCasksGroupExpanded: Bool = false
    
    var body: some View
    {
        if !brewPackagesTracker.unsuccessfullyLoadedFormulaeErrors.isEmpty
        {
            GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.terminal.badge.xmark")
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("start-page.unloaded-formulae.count-\(brewPackagesTracker.unsuccessfullyLoadedFormulaeErrors.count)")
                    
                    DisclosureGroup(isExpanded: $isFormulaeGroupExpanded)
                    {
                        List(brewPackagesTracker.unsuccessfullyLoadedFormulaeErrors)
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
        
        if !brewPackagesTracker.unsuccessfullyLoadedCasksErrors.isEmpty
        {
            GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.macwindow.badge.xmark")
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("start-page.unloaded-casks.count-\(brewPackagesTracker.unsuccessfullyLoadedCasksErrors.count)")
                    
                    DisclosureGroup(isExpanded: $isCasksGroupExpanded)
                    {
                        List(brewPackagesTracker.unsuccessfullyLoadedCasksErrors)
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
