//
//  Packages Included in Tap.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI

struct PackagesIncludedInTapList: View {
    
    @State var packages: [String]
    
    var body: some View {
        VStack
        {
            List(packages, id: \.self)
            { package in
                Text(package)
            }
        }
    }
}
