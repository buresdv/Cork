//
//  Package Preview.swift
//  Cork
//
//  Created by David Bureš on 25.08.2024.
//

import SwiftUI
import CorkModels

struct PackagePreview: View
{

    let packageToPreview: BrewPackage?

    var body: some View
    {
        if let packageToPreview
        {
            PackageDetailView(package: packageToPreview)
                .isPreview()
                .fixedSize()
        }
    }
}
