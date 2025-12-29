//
//  Adoptable Package List Template.swift
//  Cork
//
//  Created by David Bureš - P on 25.12.2025.
//

import CorkShared
import SwiftData
import SwiftUI

struct AdoptablePackageListTemplate<Content: View, Header: View, Footer: View>: View
{
    enum AdoptablePackageListType
    {
        case adoptablePackages
        case ignoredPackages
    }

    let adoptablePackageType: AdoptablePackageListType

    @Binding var searchText: String

    @ViewBuilder
    var listContent: Content

    @ViewBuilder
    var sectionHeaderContent: Header

    @ViewBuilder
    var sectionFooterContent: Footer

    @Query private var excludedApps: [ExcludedAdoptableApp]

    @State private var isShowingSearchField: Bool = false

    var body: some View
    {
        List
        {
            Section
            {
                switch adoptablePackageType
                {
                case .adoptablePackages:
                    listContent
                case .ignoredPackages:
                    listContent
                }
            } header: {
                VStack(alignment: .leading, spacing: 5)
                {
                    HStack(alignment: .firstTextBaseline)
                    {
                        sectionHeaderContent

                        Spacer()

                        Button
                        {
                            withAnimation
                            {
                                self.isShowingSearchField.toggle()
                            }
                        } label: {
                            Label("action.show-search-field", systemImage: "magnifyingglass")
                                .labelStyle(.iconOnly)
                        }
                        .accessibilityHint(isShowingSearchField ? Text("action.hide-search-field.hint") : Text("action.show-search-field.hint"))
                        .buttonStyle(.accessoryBar)
                    }
                    
                    if isShowingSearchField
                    {
                        Divider()
                        
                        CustomSearchField(
                            search: $searchText,
                            customPromptText: nil
                        )
                        .transition(.push(from: .top))
                    }
                }
            } footer: {
                sectionFooterContent
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .animation(.smooth, value: excludedApps)
        .animation(.smooth, value: isShowingSearchField)
        .transition(.push(from: .top))
    }
}
