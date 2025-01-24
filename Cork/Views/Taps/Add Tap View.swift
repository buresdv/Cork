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
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @State var progress: TapAddingStates = .ready

    @State private var requestedTap: String = ""

    @State private var forcedRepoAddress: String = ""

    @State private var tappingError: TappingError = .other

    @EnvironmentObject var availableTaps: TapTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    var isDismissable: Bool
    {
        ![.tapping, .finished].contains(progress)
    }
    
    var shouldShowSheetTitle: Bool
    {
        [.ready, .manuallyInputtingTapRepoAddress].contains(progress)
    }

    var sheetTitle: LocalizedStringKey
    {
        switch progress
        {
        case .ready:
            return "add-tap"
        case .tapping:
            return ""
        case .finished:
            return ""
        case .error:
            return ""
        case .manuallyInputtingTapRepoAddress:
            return "add-tap.manual-repo-address.title"
        }
    }

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: shouldShowSheetTitle)
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
                .navigationTitle(sheetTitle)
                .toolbar
                {
                    if isDismissable
                    {
                        ToolbarItem(placement: .cancellationAction)
                        {
                            Button
                            {
                                dismiss()
                            } label: {
                                Text("action.cancel")
                            }
                            .keyboardShortcut(.cancelAction)
                        }
                    }
                }
            }
        }
    }
}
