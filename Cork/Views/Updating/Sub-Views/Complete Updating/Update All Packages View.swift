//
//  Update All Packages View.swift
//  Cork
//
//  Created by David Bureš - P on 24.04.2026.
//

import SwiftUI

struct UpdateAllPackagesView: View
{
    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            ProgressView(updateProgressTracker.updateProgress)
            
            updateProgressTracker.streamedOutputsDisplay
        }
    }
}
