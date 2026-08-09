//
//  Taps Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import CorkShared
import SwiftUI
import ButtonKit
import CorkModels
import FactoryKit

struct TapsSection: View
{
    @InjectedObservable(\.appState) var appState: AppState
    @InjectedObservable(\.navigationManager) var navigationManager
    
    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker

    let searchText: String

    var body: some View
    {
        Section("sidebar.section.added-taps")
        {
            if appState.failedWhileLoadingTaps
            {
                HStack
                {
                    Image("custom.spigot.badge.xmark")
                    Text("error.package-loading.could-not-load-taps.title")
                }
            }
            else
            {
                if tapTracker.isBeingLoaded
                {
                    TapTracker.loadingView
                }
                else
                {
                    ForEach(displayedTaps.sorted(by: { $0.nameInternal < $1.nameInternal }))
                    { tap in
                        NavigationLink(value: NavigationManager.DetailDestination.tap(tap: tap))
                        {
                            TapListItem(tap: tap)
                        }
                    }
                }
            }
        }
    }

    private var displayedTaps: Set<BrewTap>
    {
        if searchText.isEmpty || searchText.contains("#")
        {
            return tapTracker.successfullyLoadedTaps
        }
        else
        {
            return tapTracker.successfullyLoadedTaps.filter({ $0.name(withPrecision: .full).localizedCaseInsensitiveContains(searchText) })
        }
    }
}
