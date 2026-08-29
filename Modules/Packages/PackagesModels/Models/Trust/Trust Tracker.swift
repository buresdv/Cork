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
@Observable
public class TrustTracker
{    
    public var trustedTapNames: [BrewTap.BrewTapName]
    
    public init(trustedTapNames: [BrewTap.BrewTapName]) {
        self.trustedTapNames = trustedTapNames
    }
}

public extension Container
{
    
    var trustTracker: Factory<TrustTracker>
    {
        Factory(self)
        {
            TrustTracker(trustedTapNames: .init())
        }
        .singleton
    }
}
