//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct AddPackageView: View {
    @Binding var isShowingSheet: Bool
    @State private var packageRequested: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Search For Package...", text: $packageRequested)
            
            HStack {
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Text("Add")
                }
            }
        }
        .padding()
    }
}

