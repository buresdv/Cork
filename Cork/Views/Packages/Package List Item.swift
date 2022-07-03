//
//  Package List Item.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct PackageListItem: View {
    var packageItem: BrewPackage
    
    var body: some View {
        HStack {
            Text(packageItem.name)
            
            Spacer()
            
            Image(systemName: "arrow.right")
        }
    }
}
