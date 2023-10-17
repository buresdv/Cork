//
//  Updating Finished.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct UpdatingFinishedStateView: View
{
    @Binding var packageUpdatingStep: PackageUpdatingProcessSteps

    var body: some View
    {
        Text("update-packages.updating.finished")
            .onAppear
            {
                packageUpdatingStep = .finished
            }
    }
}
