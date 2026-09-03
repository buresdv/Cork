//
//  Package warnings View.swift
//  Cork
//
//  Created by David Bureš - P on 01.09.2026.
//

import SwiftUI
import CorkTerminalFunctions

struct PackageWarningsView: View
{
    let warnings: [TerminalOutput]?
    
    @State private var isWarningsListExpanded: Bool = false
    
    var body: some View
    {
        if let warnings
        {
            Section
            {
                HStack(alignment: isWarningsListExpanded ? .top : .center, spacing: 10)
                {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.orange)
                    
                    HomebrewWarningsDropdown(isExpanded: $isWarningsListExpanded, warnings: warnings)
                }
            }
        }
    }
}
