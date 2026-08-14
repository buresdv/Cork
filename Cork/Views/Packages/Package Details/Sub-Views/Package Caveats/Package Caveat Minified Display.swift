//
//  Package Caveat Minified Display.swift
//  Cork
//
//  Created by David Bureš on 01.10.2023.
//

import CorkShared
import Defaults
import SwiftUI

struct PackageCaveatMinifiedDisplayView: View
{
    @Default(.caveatDisplayOptions) var caveatDisplayOptions: PackageCaveatDisplay

    let caveats: String?

    @State private var isShowingCaveatPopover: Bool = false

    var body: some View
    {
        if let caveats
        {
            if !caveats.isEmpty
            {
                if caveatDisplayOptions == .mini
                {
                    StatusPill(localizedText: "package-details.caveats.available", systemImage: "text.pad.header", color: .indigo)
                        .onTapGesture
                        {
                            isShowingCaveatPopover.toggle()
                        }
                        .popover(isPresented: $isShowingCaveatPopover)
                        {
                            Text(.init(caveats.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n\n", with: "\n")))
                                .font(.system(size: 13))
                                .textSelection(.enabled)
                                .lineSpacing(5)
                                .padding()
                                .help("package-details.caveats.help")
                        }
                }
            }
        }
    }
}
