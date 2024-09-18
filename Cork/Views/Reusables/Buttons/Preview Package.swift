//
//  Preview Package.swift
//  Cork
//
//  Created by David Bureš on 16.09.2024.
//

import SwiftUI
import CorkShared

/// Preview a package according to its name
struct PreviewPackageButton: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    let packageNameToPreview: String
    
    var body: some View
    {
        Button
        {
            let constructedPackage: BrewPackage = .init(name: packageNameToPreview, type: .formula, installedOn: nil, versions: [], sizeInBytes: nil)
            
            openWindow(value: constructedPackage)
        } label: {
            Text("preview-package.action")
        }
    }
}

struct PreviewPackageButtonWithCustomAction: View
{
    
    let action: () -> Void
    var body: some View {
        Button
        {
            action()
        } label: {
            Text("preview-package.action")
        }
    }
}
