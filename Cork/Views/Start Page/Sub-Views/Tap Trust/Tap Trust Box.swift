//
//  Tap Trust Box.swift
//  Cork
//
//  Created by David Bureš - P on 25.08.2026.
//

import CorkModels
import CorkShared
import FactoryKit
import SwiftUI

struct TapTrustBox: View
{
    @LazyInjected(\.appConstants) var appConstants: AppConstants

    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker
    @InjectedObservable(\.trustTracker) var trustTracker: TrustTracker
    
    var body: some View
    {
        GroupBoxHeadlineGroupWithArbitraryContent(image: .init(systemName: "rosette"))
        {
            VStack(alignment: .leading, spacing: 5)
            {
                Text("start-page.trust.title")
                    .font(.headline)

                GroupBox
                {
                    VStack
                    {
                        VStack(alignment: .center, spacing: 3)
                        {
                            Text("start-page.trust.trust-zone.title")
                                .font(.subheadline)

                            Text("start-page.trust.trust-zone.instructions")
                                .font(.caption)
                            
                            LazyHStack
                            {
                                ForEach(trustTracker.trustedTapNames, id: \.tapName)
                                { trustedTap in
                                    TapDraggableView(tapName: trustedTap)
                                }
                            }
                        }
                        .dropDestination(for: BrewTap.self)
                        { items, _ in
                            
                            guard let tap: BrewTap = items.first else { return false }

                            withAnimation
                            {
                                Task
                                {
                                    do
                                    {
                                        try await tap.trustSelf()
                                    } catch let tapTrustingError {
                                        print(tapTrustingError)
                                    }
                                }
                                trustTracker.trustedTapNames.append(tap.nameInternal)
                            }
                            
                            return true
                        }

                        Divider()

                        VStack(alignment: .center, spacing: 3)
                        {
                            Text("start-page.trust.untrust-zone.title")
                                .font(.subheadline)

                            Text("start-page.trust.untrust-zone.instructions")
                                .font(.caption)
                            
                            LazyHStack
                            {
                                
                                ForEach(trustTracker.untrustedTapNames, id: \.self)
                                { loadedTap in
                                    TapDraggableView(tapName: loadedTap)
                                }
                            }
                             
                        }
                        .dropDestination(for: BrewTap.self)
                        { items, _ in
                            guard let tap = items.first else { return false }

                            withAnimation
                            {
                                trustTracker.trustedTapNames.removeAll
                                { tapInTrustTrackerName in
                                    tapInTrustTrackerName == tap.nameInternal
                                }
                            }
                            
                            return true
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
