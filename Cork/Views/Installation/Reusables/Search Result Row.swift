//
//  Search Result Row.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct SearchResultRow: View
{
    @State var brewData: BrewDataStorage

    @State var packageName: String
    @State var isCask: Bool

    var body: some View
    {
        HStack
        {
            Text(packageName)
            
            if !isCask
            {
                if brewData.installedFormulae.contains(where: { $0.name == packageName })
                {
                    PillText(text: "Already Installed")
                }
            }
            else
            {
                if brewData.installedCasks.contains(where: { $0.name == packageName })
                {
                    PillText(text: "Already Installed")
                }
            }
            
        }
    }
}
