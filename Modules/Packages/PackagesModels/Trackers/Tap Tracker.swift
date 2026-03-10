//
//  Tap Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 13.05.2025.
//

import FactoryKit
import Foundation
import Observation

@Observable @MainActor
public class TapTracker
{
    @Injected(\.appConstants) @ObservationIgnored var appConstants

    @Injected(\.appState) @ObservationIgnored var appState

    public init()
    {
        self.addedTaps = .init()
    }

    public var addedTaps: BrewTaps

    public var successfullyLoadedTaps: Set<BrewTap>
    {
        return Set(addedTaps.compactMap
        { rawResult in
            if case .success(let success) = rawResult
            {
                return success
            }
            else
            {
                return nil
            }
        })
    }

    public var unsucessfullyLoadedTaps: Set<TapLoadingError>
    {
        return Set(addedTaps.compactMap
        { rawResult in
            if case .failure(let failure) = rawResult
            {
                return failure
            }
            else
            {
                return nil
            }
        })
    }
}

public extension TapTracker
{
    var numberOfAddedTaps: Int
    {
        return self.addedTaps.count
    }
}
