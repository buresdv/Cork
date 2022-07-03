//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct PackageDetailView: View {
    @State var packageName: String
    
    var body: some View {
        Text(packageName)
    }
}
