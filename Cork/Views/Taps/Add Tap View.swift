//
//  Add Tap.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import SwiftUI

enum TapAddingStates
{
    case ready, tapping, finished, error, manuallyInputtingTapRepoAddress
}

enum TapInputErrors
{
    case empty, missingSlash
}

enum TappingError: String
{
    case repositoryNotFound = "Repository not found"
    case other = "An error occurred while tapping"
}

struct AddTapView: View
{
    @State var progress: TapAddingStates = .ready

    @State private var requestedTap: String = ""
    
    @State private var forcedRepoAddress: String = ""

    @State private var tappingError: TappingError = .other

    @EnvironmentObject var availableTaps: AvailableTaps
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var body: some View
    {
        VStack
        {
            switch progress
            {
            case .ready:
                AddTapInitialView(
                    requestedTap: $requestedTap,
                    forcedRepoAddress: $forcedRepoAddress,
                    progress: $progress,
                    isShowingManualRepoAddressInputField: false
                )

            case .tapping:
                AddTapAddingView(
                    requestedTap: requestedTap,
                    forcedRepoAddress: forcedRepoAddress,
                    progress: $progress,
                    tappingError: $tappingError
                )

            case .finished:
                AddTapFinishedView(
                    requestedTap: requestedTap
                )

            case .error:
                AddTapErrorView(
                    tappingError: tappingError,
                    requestedTap: requestedTap,
                    progress: $progress
                )

            case .manuallyInputtingTapRepoAddress:
                AddTapInitialView(
                    requestedTap: $requestedTap,
                    forcedRepoAddress: $forcedRepoAddress,
                    progress: $progress,
                    isShowingManualRepoAddressInputField: true
                )
            }
        }
        .padding()
    }
}
