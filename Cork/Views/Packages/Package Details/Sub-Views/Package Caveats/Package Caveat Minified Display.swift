//
//  Package Caveat Minified Display.swift
//  Cork
//
//  Created by David Bureš on 01.10.2023.
//

import SwiftUI
import CorkShared
import Defaults

struct PackageCaveatMinifiedDisplayView: View
{
    @Default(.caveatDisplayOptions) var caveatDisplayOptions

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
                    OutlinedPillText(text: "package-details.caveats.available", color: .indigo)
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
