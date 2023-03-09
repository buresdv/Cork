//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import SwiftUI

struct UpdatePackagesView: View {
    
    @Binding var isShowingSheet: Bool
    
    @State var packageUpdatingStage: PackageUpdatingProcessSteps = .ready
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch packageUpdatingStage {
                case .ready:
                    Text("Ready")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
                            {
                                packageUpdatingStage = .checkingForUpdates
                            }
                        }
                case .checkingForUpdates:
                    Text("Updating")
                        .onAppear {
                            Task
                            {
                                await updatePackages()
                                packageUpdatingStage = .updatingPackages
                            }
                        }
                case .updatingPackages:
                    Text("Upgrading")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
                            {
                                packageUpdatingStage = .finished
                            }
                        }
                    
                case .finished:
                    DisappearableSheet(isShowingSheet: $isShowingSheet) {
                        ComplexWithIcon(systemName: "checkmark.seal")
                        {
                            HeadlineWithSubheadline(headline: "Sucessfully upgraded packages", subheadline: "There were no errors", alignment: .leading)
                        }
                    }
            }
        }
        .padding()
    }
}
