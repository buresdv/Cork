//
//  Packages Included in Tap.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI

struct PackagesIncludedInTapList: View {
    
    @State var packages: [String]
    
    @State private var searchString: String = ""
    
    var body: some View {
        VStack(spacing: 0)
        {
            TextField("Search...", text: $searchString)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array( searchString.isEmpty ? packages.enumerated() : packages.filter({ $0.contains(searchString) }).enumerated()), id: \.offset)
                    { index, package in
                        Text(package)
                            .padding(6)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .background(index % 2 == 0 ? Color(nsColor: NSColor.alternatingContentBackgroundColors[0]) : Color(nsColor: NSColor.alternatingContentBackgroundColors[1]))
                    }
                }
            }
            .frame(height: 150)
        }
        .border(Color(nsColor: .lightGray))
    }
}
