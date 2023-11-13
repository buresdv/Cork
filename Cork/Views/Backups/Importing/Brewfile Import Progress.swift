//
//  Brewfile Import Progress.swift
//  Cork
//
//  Created by David Bureš on 11.11.2023.
//

import SwiftUI

struct BrewfileImportProgressView: View
{
    
    @EnvironmentObject var appState: AppState
    
    var body: some View
    {
        Group
        {
            switch appState.brewfileImportingStage {
                case .importing:
                    HStack(alignment: .center, spacing: 20)
                    {
                        ProgressView()
                        
                        Text("brewfile.import.progress")
                    }
                case .finished:
                    DisappearableSheet(isShowingSheet: $appState.isShowingBrewfileImportProgress) {
                        ComplexWithIcon(systemName: "checkmark.seal") {
                            HeadlineWithSubheadline(headline: "brewfile.import.finished.title", subheadline: "brewfile.import.finished.message", alignment: .leading)
                        }
                        .fixedSize()
                    }
            }
        }
        .padding()
    }
}
