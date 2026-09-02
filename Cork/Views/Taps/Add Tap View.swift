//
//  Add Tap.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import FactoryKit
import SwiftUI

enum TapAddingStates: Equatable
{
    case ready
    case tapping(
        tap: BrewTap
    )
    case finished
    case error(TappingError)
    case manuallyInputtingTapRepoAddress
}

enum TapInputErrors: Error
{
    case empty, missingSlash, invalidHost, invalidName(BrewTap.BrewTapName.BrewTapNameInitializationError)
}

struct AddTapView: View
{
    @Injected(\.appConstants) var appConstants: AppConstants

    @Environment(\.dismiss) var dismiss: DismissAction

    @State var progress: TapAddingStates = .ready

    @State private var requestedTap: String = ""

    @State private var forcedRepoAddress: String = AppConstants.shared.gitHubURL.absoluteString

    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker

    var isDismissable: Bool
    {
        switch progress
        {
        case .tapping, .finished:
            return false
        default:
            return true
        }
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

    @ViewBuilder
    var tapSheetContent: some View
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

        case .tapping(let tap):
            AddTapAddingView(
                requestedTap: tap,
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

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: shouldShowSheetTitle)
            {
                tapSheetContent
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
