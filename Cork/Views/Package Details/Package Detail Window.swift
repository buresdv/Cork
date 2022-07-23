//
//  Package Detail View.swift
//  Cork
//
//  Created by David Bureš on 22.07.2022.
//

import SwiftUI

struct PackageDetailWindow: View {
    @State var package: String
    
    var body: some View {
        VStack {
            Text(package)
            
        }
        .frame(width: 200, height: 100, alignment: .topLeading)
        .onAppear {
            Task {
            }
        }
    }
}
