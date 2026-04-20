//
//  Updating Finished.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct UpdatingFinishedStateView: View
{
    @Environment(UpdateProgressTracker.self) var updateProgressTracker

    var body: some View
    {
        Text("update-packages.updating.finished")
            .onAppear
            {
                updateProgressTracker.updatingState = .finished
            }
    }
}
