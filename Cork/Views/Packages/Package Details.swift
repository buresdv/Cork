//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

class SelectedPackageInfo: ObservableObject {
    @Published var contents: String?
}

struct PackageDetailView: View {
    @State var package: BrewPackage
    
    @State var isCask: Bool
    
    @StateObject var packageInfo: SelectedPackageInfo
    
    var body: some View {
        VStack {
            Text(package.name)
                .font(.title)
            Text(returnFormattedVersions(package.versions))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if packageInfo.contents == nil {
                VStack {
                    ProgressView()
                    Text("Loading package info...")
                }
            } else {
                ScrollView {
                    Text(packageInfo.contents!)
                }
            }
            
        }
        .onAppear {
            Task {
                if !isCask {
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json", package.name])
                } else {
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json=v2", "--cask", package.name])
                }
                
            }
        }
        .onDisappear {
            packageInfo.contents = nil
        }
    }
}
