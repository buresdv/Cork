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
    @AppStorage("openRealTimeTerminalOutputByDefault") var openRealTimeTerminalOutputByDefault: Bool = false

    @Binding var lineArray: [RealTimeTerminalLine]

    @Binding var isRealTimeTerminalOutputExpanded: Bool

    @State var forceKeepTerminalOutputInMemory: Bool = false

    var body: some View
    {
        if showRealTimeTerminalOutputOfOperations
        {
            DisclosureGroup(isRealTimeTerminalOutputExpanded ? "add-package.install.hide-details" : "add-package.install.show-details", isExpanded: $isRealTimeTerminalOutputExpanded)
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
            .onAppear
            { /// This has to be here so that the real-time output dropdown can be open according to user preference, while, at the same time, enabling the user to open/close the dropdown without also changing their preference in the process
                isRealTimeTerminalOutputExpanded = openRealTimeTerminalOutputByDefault
            }
            .onDisappear
            {
                if !forceKeepTerminalOutputInMemory
                {
                    AppConstants.logger.debug("Purging saved real time output")

                    lineArray = .init()
                }
                else
                {
                    AppConstants.logger.debug("Forced to keep previous output in memory")
                }
            }
        }
    }
}
