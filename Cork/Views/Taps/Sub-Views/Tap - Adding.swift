//
//  Tap - Adding.swift
//  Cork
//
//  Created by David Bureš on 05.12.2023.
//

import SwiftUI

struct AddTapAddingView: View
{
    let requestedTap: String
    let forcedRepoAddress: String
    
    @Binding var progress: TapAddingStates
    @Binding var tappingError: TappingError
    
    var body: some View
    {
        ProgressView
        {
            Text("add-tap.progress-\(requestedTap)")
        }
        .task(priority: .medium)
        {
            var tapResult: String
            
            if forcedRepoAddress.isEmpty
            {
                tapResult = await addTap(name: requestedTap)
            }
            else
            {
                tapResult = await addTap(name: requestedTap, forcedRepoAddress: forcedRepoAddress)
            }

            AppConstants.logger.debug("Result: \(tapResult, privacy: .public)")

            if tapResult.contains("Tapped")
            {
                AppConstants.logger.info("Tapping was successful!")
                progress = .finished
            }
            else
            {
                progress = .error
                tappingError = .other

                if tapResult.contains("Repository not found")
                {
                    AppConstants.logger.error("Repository was not found")

                    tappingError = .repositoryNotFound
                }
            }
        }
    }
}
