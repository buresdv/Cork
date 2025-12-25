//
//  Adoptable Packages Search Field.swift
//  Cork
//
//  Created by David Bureš - P on 24.12.2025.
//

import SwiftUI

struct AdoptablePackagesSearchField: View
{
    enum AssociatedAdoptedPackageListingType
    {
        case adoptableApps
        case excludedApps
    }
    
    @Binding var searchText: String
    
    let associatedAdoptablePackages: AssociatedAdoptedPackageListingType
    
    var body: some View
    {
        CustomSearchField(
            search: $searchText,
            customPromptText: associatedAdoptablePackages == .adoptableApps ? String(localized: "start-page.adoptable-packages.search.adoptable-apps") : String(localized: "start-page.adoptable-packages.search.excluded-apps")
        )
    }
}
