//
//  Package Detail View.swift
//  Cork
//
//  Created by David Bureš on 22.07.2022.
//

import SwiftUI

class LoadingStatus: ObservableObject {
    @Published var isLoadingPackageInfo: Bool = true
}

struct PackageDetailWindow: View {
    @State var package: String
    @State var tracker: SearchResultTracker
    
    @State private var packageInfoLoadingStatus: LoadingStatus = LoadingStatus()
    
    @State private var displayedPackage: SearchResult? = nil
    @State private var packageInfo: SelectedPackageInfo = SelectedPackageInfo()
    
    @State private var assembledPackage: BrewPackage? = nil
    
    var body: some View {
        VStack {
            if displayedPackage != nil {
                
                if packageInfo != nil {
                    if assembledPackage != nil {
                        PackageDetailView(package: assembledPackage!, isCask: displayedPackage!.isCask, packageInfo: packageInfo)
                    } else {
                        ProgressView()
                    }

                }
                
            } else {
                Text("An error occured while getting package name")
                    .font(.headline)
                Text("Report this to github")
            }
            
            HStack(alignment: .bottom) {
                Button {
                    NSApplication.shared.keyWindow?.close()
                } label: {
                    Text("Close")
                }

            }
            .padding()
        }
        .frame(minWidth: 300, minHeight: 200, alignment: .topLeading)
        .onAppear {
            if tracker.foundFormulae.contains(where: { result in
                result.isCask == false
            }) {
                print("\(package) is Formula")
                displayedPackage = SearchResult(packageName: package, isCask: false)
                
                Task {
                    packageInfoLoadingStatus.isLoadingPackageInfo = true
                    
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json", package])
                    
                    print(packageInfo.contents)
                    
                    assembledPackage = BrewPackage(name: package, versions: ["\(extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .version))"])
                    
                    packageInfoLoadingStatus.isLoadingPackageInfo = false
                }
        
            } else {
                print("\(package) is Cask")
                displayedPackage = SearchResult(packageName: package, isCask: true)
                
                Task {
                    packageInfoLoadingStatus.isLoadingPackageInfo = true
                    
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json=v2", "--cask", package])
                    
                    print(packageInfo.contents)
                    
                    assembledPackage = BrewPackage(name: package, versions: ["\(extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .version))"])
                    
                    packageInfoLoadingStatus.isLoadingPackageInfo = false
                }
                
            }
        }
    }
}
