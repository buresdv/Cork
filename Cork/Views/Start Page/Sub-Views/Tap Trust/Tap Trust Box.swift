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
    
    var explicitlyTrustedTaps: [BrewTap]
    {
        return tapTracker.tapsEligibleForTrustModification.filter({ $0.isTrusted == .explicit(.trusted) }).sorted(by: { $0.nameInternal < $1.nameInternal })
    }

    var tapsRequiringAdditionalManualTrust: [BrewTap]
    {
        return tapTracker.tapsEligibleForTrustModification.filter({ $0.isTrusted != .explicit(.trusted) }).sorted(by: { $0.nameInternal < $1.nameInternal })
    }
    
    var body: some View
    {
        GroupBoxHeadlineGroupWithArbitraryContent(image: "rosette")
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
                                ForEach(explicitlyTrustedTaps)
                                { trustedTap in
                                    TapDraggableView(tap: trustedTap)
                                }
                            }
                        }
                        .dropDestination(for: BrewTap.self)
                        { items, _ in
                            
                            Task {
                                guard let tap = items.first else { return false }

                                await tapTracker.tapsEligibleForTrustModification.filter({ $0 == tap }).first!.changeTrust(to: .explicit(.trusted))
                                
                                return true
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
                                ForEach(tapsRequiringAdditionalManualTrust)
                                { loadedTap in
                                    TapDraggableView(tap: loadedTap)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
