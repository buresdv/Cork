//
//  Tap - Adding.swift
//  Cork
//
//  Created by David Bureš on 05.12.2023.
//

import SwiftUI
import CorkShared
import CorkModels
import FactoryKit

struct AddTapAddingView: View
{
    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker
    
    let requestedTap: String
    let forcedRepoAddress: URL?

    @Binding var progress: TapAddingStates

    var body: some View
    {
        ProgressView
        {
            Text("add-tap.progress-\(requestedTap)")
        }
        .task
        {

            do throws(TappingError)
            {
                try await tapTracker.addTap(name: requestedTap, forcedRepoAddress: forcedRepoAddress)
                
                progress = .finished
            }
            catch let tapAddingError
            {
                progress = .error(tapAddingError)
            }
        }
    }
}
