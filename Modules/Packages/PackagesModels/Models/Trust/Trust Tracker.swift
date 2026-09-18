//
//  Trust Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 30.08.2026.
//

import Foundation
import FactoryKit
import CorkShared

// TODO: Implement the other trustable stuff
@Observable @MainActor
public class TrustTracker
{
    @Injected(\.tapTracker) @ObservationIgnored var tapTracker
    
    public var trustedTapNames: [BrewTap.BrewTapName]
    
    @MainActor
    public var untrustedTapNames: [BrewTap.BrewTapName]
    {
        return Array(Set(tapTracker.tapsEligibleForTrustModification.map( \.nameInternal )).subtracting(Set(self.trustedTapNames)))
    }
    
    public init(trustedTapNames: [BrewTap.BrewTapName])
    {
        self.trustedTapNames = trustedTapNames
    }
}

public extension Container
{
    @MainActor
    var trustTracker: Factory<TrustTracker>
    {
        Factory(self)
        {
            TrustTracker(trustedTapNames: .init())
        }
        .singleton
    }
}
