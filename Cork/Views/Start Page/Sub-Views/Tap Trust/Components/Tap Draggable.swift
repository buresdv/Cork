//
//  Tap Draggable.swift
//  Cork
//
//  Created by David Bureš - P on 26.08.2026.
//

import SwiftUI
import CorkModels
import FactoryKit

struct TapDraggableView: View
{
    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker
    
    let tapName: BrewTap.BrewTapName
    
    private let relevantTapFromTracker: BrewTap
    
    public init(tapName: BrewTap.BrewTapName)
    {
        self.tapName = tapName
        self.relevantTapFromTracker = Container.shared.tapTracker.resolve().tapsEligibleForTrustModification.filter({ $0.nameInternal == tapName }).first!
    }
    
    var body: some View
    {
        GroupBox
        {
            Text(relevantTapFromTracker.name(withPrecision: .full))
                .padding()
        }
        .draggable(relevantTapFromTracker)
    }
}
