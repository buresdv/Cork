//
//  Package Caveat Full Display.swift
//  Cork
//
//  Created by David Bureš on 01.10.2023.
//

import SwiftUI

struct PackageCaveatFullDisplayView: View
{
    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full

    let caveats: String?

    @Binding var isShowingExpandedCaveats: Bool
    @State private var canExpandCaveats: Bool = false

    var body: some View
    {
        if let caveats
        {
            if !caveats.isEmpty
            {
                if caveatDisplayOptions == .full
                {
                    HStack(alignment: .top, spacing: 10)
                    {
                        Image(systemName: "note.text")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.cyan)

                        /// Remove the last newline from the text if there is one, and replace all double newlines with a single newline
                        VStack(alignment: .leading, spacing: 5)
                        {
                            let text: some View = Text(
                                .init(
                                    caveats
                                        .trimmingCharacters(in: .whitespacesAndNewlines)
                                        .replacingOccurrences(of: "\n\n", with: "\n")
                                )
                            )
                            .lineSpacing(5)

                            text
                                .textSelection(.enabled)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .lineLimit(isShowingExpandedCaveats ? nil : 2)
                                .background
                                {
                                    ViewThatFits(in: .vertical)
                                    {
                                        text.hidden()
                                        Color.clear.onAppear { canExpandCaveats = true }
                                    }
                                }

                            if canExpandCaveats
                            {
                                Button
                                {
                                    withAnimation
                                    {
                                        isShowingExpandedCaveats.toggle()
                                    }
                                } label: {
                                    Text(isShowingExpandedCaveats ? "package-details.caveats.collapse" : "package-details.caveats.expand")
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                    .padding(2)
                }
            }
        }
    }
}
