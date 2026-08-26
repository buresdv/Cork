//
//  Tap Trust Box.swift
//  Cork
//
//  Created by David Bureš - P on 25.08.2026.
//

import CorkModels
import FactoryKit
import SwiftUI

struct TapTrustBox: View
{
    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker

    var relevantTapsForTrustModification: Set<BrewTap>
    {
        return self.tapTracker.successfullyLoadedTaps.filter
        { candidateForFiltering in
            if case .external = candidateForFiltering.nameInternal.repo
            {
                return true
            }
            else
            {
                return false
            }
        }
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
                        }
                        .dropDestination(for: BrewTap.self)
                        { items, _ in
                            print(items)
                            guard let tap = items.first else { return false }

                            print(tap.name(withPrecision: .full))

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
                                ForEach(relevantTapsForTrustModification.sorted(by: { $0.nameInternal < $1.nameInternal }))
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
