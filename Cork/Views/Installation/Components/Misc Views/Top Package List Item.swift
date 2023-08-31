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
            Text(topPackage.packageName)
            
            Spacer()
            
            Text("\(String(topPackage.packageDownloads)) downloads")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}
