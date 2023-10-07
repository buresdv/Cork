//
//  Live Code Output.swift
//  Cork
//
//  Created by David Bureš on 07.10.2023.
//

import SwiftUI

struct LiveTerminalOutputView: View
{
    @AppStorage("showRealTimeTerminalOutputOfOperations") var showRealTimeTerminalOutputOfOperations: Bool = false

    @Binding var lineArray: [RealTimeTerminalLine]

    var body: some View
    {
        if showRealTimeTerminalOutputOfOperations
        {
            DisclosureGroup("add-package.install.show-details")
            {
                ScrollViewReader
                { proxy in
                    ScrollView
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            ForEach(lineArray)
                            { line in
                                Text(line.line)
                                    .id(line.id)
                            }
                        }
                    }
                    .onChange(of: lineArray)
                    { _ in
                        proxy.scrollTo(lineArray.last?.id, anchor: .bottom)
                    }
                    .frame(width: 300, height: 200)
                    .fixedSize()
                    .border(Color(nsColor: NSColor.separatorColor))
                }
                // }
            }
            .onDisappear
            {
                print("Purging saved real time output")

                lineArray = .init()
            }
        }
    }
}
