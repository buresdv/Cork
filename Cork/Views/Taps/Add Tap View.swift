//
//  Add Tap.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import SwiftUI
import CorkModels
import FactoryKit
import CorkTerminalFunctions

enum TapAddingStates: Equatable
{
    case ready, tapping, finished, error(TappingError), manuallyInputtingTapRepoAddress
}

enum TapInputErrors
{
    case empty, missingSlash
}

struct AddTapView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @State var progress: TapAddingStates = .ready

    @State private var requestedTap: String = ""

    @State private var forcedRepoAddress: URL?

    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker

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
                Group
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
                            progress: $progress
                        )

                    case .finished:
                        AddTapFinishedView(
                            requestedTap: requestedTap
                        )

                    case .error(let error):
                        AddTapErrorView(
                            tappingError: error,
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
