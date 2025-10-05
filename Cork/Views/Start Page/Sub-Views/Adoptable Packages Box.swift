//
//  Adoptable Packages Box.swift
//  Cork
//
//  Created by David Bureš - P on 04.10.2025.
//

import SwiftUI

struct AdoptablePackagesBox: View
{
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    var body: some View
    {
        GroupBoxHeadlineGroupWithArbitraryImageAndContent(imageName: "custom.shippingbox.2.badge.arrow.down")
        {
            if !brewPackagesTracker.adoptableCasks.isEmpty
            {
                Text("start-page.adoptable-packages.available.\(10)")
                    .font(.headline)
            }
        }
    }
}
