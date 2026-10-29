//
//  Homebrew Warnings Section.swift
//  Cork
//
//  Created by David Bureš - P on 08.09.2026.
//

import SwiftUI
import FactoryKit

struct HomebrewWarningsSection: View
{
    @InjectedObservable(\.warningsTracker) var warningsTracker
    
    var body: some View
    {
        GroupBoxHeadlineGroupWithArbitraryImageAndContent(image: .init("custom.mug.trianglebadge.exclamationmark"))
        {
            VStack(alignment: .leading, spacing: 5)
            {
                Text("start-page.homebrew-warnings.encountered.\(warningsTracker.capturedWarnings.count).warnings.title")
                .font(.headline)
                
                Text("label.warnings.dont-bother-cork-its-the-fault-of-someone-else")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HomebrewWarningsDropdown()
            }
        }
    }
}
