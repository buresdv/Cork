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
                            
                            Task {
                                guard let tap = items.first else { return false }

                                print(tap.name(withPrecision: .full))
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
                                ForEach(tapTracker.tapsEligibleForTrustModification.sorted(by: { $0.nameInternal < $1.nameInternal }))
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
        .task {
            do
            {
                let trustFileContents: TrustFileContents = try await tapTracker.readTrustFile()
            } catch let trustFileReadingError {
                AppConstants.shared.logger.error("Failed to read contents of trust file on start page load: \(trustFileReadingError.localizedDescription)")
            }
        }
    }
}
