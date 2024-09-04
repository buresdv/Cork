//
//  Package Preview.swift
//  Cork
//
//  Created by David Bureš on 25.08.2024.
//

import SwiftUI

@available(macOS 14.0, *)
struct PackagePreview: View
{
    @Environment(\.dismissWindow) var dismissWindow: DismissWindowAction

    let packageToPreview: BrewPackage?
    
    /*
    init(packageToPreview: BrewPackage?)
    {
        self.packageToPreview = packageToPreview
        
        /*
        if packageToPreview == nil
        {
            // Tell the window to fuck off when it's not supposed to show up yet
            withTransaction(\.dismissBehavior, .destructive)
            {
                dismissWindow(id: .previewWindowID)
            }
        }
         */
    }
     */

    var body: some View
    {
        if let packageToPreview
        {
            PackageDetailView(package: packageToPreview)
                .fixedSize()
        }
    }
}
