//
//  Package Preview.swift
//  Cork
//
//  Created by David Bureš on 25.08.2024.
//

import SwiftUI

struct PackagePreview: View
{

    let selectedPackageToPreview: AddFormulaView.PackageSelectedToBeInstalled?

    var body: some View
    {
        if let finalPackageOfRelevantVersion = selectedPackageToPreview?.constructPackageOfRelevantVersion()
        {
            PackageDetailView(package: finalPackageOfRelevantVersion)
                .isPreview()
                .fixedSize()
        }
    }
}
