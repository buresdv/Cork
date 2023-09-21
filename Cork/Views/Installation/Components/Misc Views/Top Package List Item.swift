//
//  Top Package List Item.swift
//  Cork
//
//  Created by David Bureš on 30.08.2023.
//

import SwiftUI

struct TopPackageListItem: View
{
    
    let topPackage: TopPackage
    
    var body: some View
    {
        HStack(alignment: .center)
        {
            SanitizedPackageName(packageName: topPackage.packageName, shouldShowVersion: true)
            
            Spacer()
            
            Text("add-package.top-packages.list-item \(topPackage.packageDownloads)")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}
