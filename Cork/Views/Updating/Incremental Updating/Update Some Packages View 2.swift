//
//  Update Some Packages View.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct UpdateSomePackagesView: View {
    
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)
        {
            Text("Would update:")
            ForEach(outdatedPackageTracker.outdatedPackages.filter({ $0.isMarkedForUpdating })) { outdatedPackage in
                Text(outdatedPackage.packageName)
            }
        }
        .padding()
    }
}
