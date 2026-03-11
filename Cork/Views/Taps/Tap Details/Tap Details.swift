//
//  Tap Details.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI
import CorkShared
import ButtonKit
import CorkModels
import CorkTerminalFunctions

extension EnvironmentValues
{
    @Entry var selectedTap: BrewTap?
}

struct TapDetailView: View, Sendable
{
    enum TapDetailsLoadingState
    {
        case loading
        case loaded(info: TapInfo)
        case erroredOut(withErrorText: String)
    }
    
    let tap: BrewTap

    @Environment(AppState.self) var appState: AppState
    @Environment(TapTracker.self) var tapTracker: TapTracker
    
    @State var tapInfo: TapInfo?

    @State private var loadingState: TapDetailsLoadingState = .loading

    var body: some View
    {
        VStack(alignment: .leading)
        {
            switch loadingState {
            case .loading:
                BrewTap.loadingView
            case .loaded(let tapInfo):
                VStack(alignment: .leading, spacing: 10)
                {
                    FullSizeGroupedForm
                    {
                        TapDetailsInfo(
                            tap: tap,
                            tapInfo: tapInfo
                        )
                        
                        TapDetailsIncludedPackages(
                            includedFormulae: tapInfo.includedFormulaeWithAdditionalMetadata,
                            includedCasks: tapInfo.includedCasksWithAdditionalMetadata
                        )
                    }
                    .scrollDisabled(true)
                    
                    ButtonBottomRow
                    {
                        Spacer()
                        
                        AsyncButton
                        {
                            try await tapTracker.removeTap(tapToRemove: tap, purpose: .removeFromHomebrewAndTracker)
                        } label: {
                            Text("tap-details.remove-\(tap.name(withPrecision: .full))")
                        }
                        .asyncButtonStyle(.trailing)
                        .disabledWhenLoading()
                    }
                }
            case .erroredOut(let withErrorText):
                InlineFatalError(errorMessage: "alert.generic.couldnt-parse-json", errorDescription: withErrorText)
            }
        }
        .environment(\.selectedTap, tap)
        .frame(minWidth: 450, minHeight: 400, alignment: .topLeading)
        .task(id: tap.id)
        {
            do
            {
                tapInfo = try await tap.loadDetails()
            } catch let tapDetailsLoadingError {
                loadingState = .erroredOut(withErrorText: tapDetailsLoadingError.localizedDescription)
            }
        }
    }
}
