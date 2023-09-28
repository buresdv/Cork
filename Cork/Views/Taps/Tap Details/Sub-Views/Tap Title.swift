//
//  Tap Details Title.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct TapDetailsTitle: View
{
    let tap: BrewTap
    let isOfficial: Bool

    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            HStack(alignment: .center, spacing: 5)
            {
                Text(tap.name)
                    .font(.title)

                if isOfficial
                {
                    Image(systemName: "checkmark.shield")
                        .help("tap-details.official-\(tap.name)")
                }
            }
        }
    }
}
