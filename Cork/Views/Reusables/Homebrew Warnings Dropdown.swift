//
//  Homebrew Warning Dropdown.swift
//  Cork
//
//  Created by David Bureš - P on 01.09.2026.
//

import CorkTerminalFunctions
import SwiftUI

struct HomebrewWarningsDropdown: View
{
    /// Optional external binding
    var isExpanded: Binding<Bool>? = nil

    /// Internal binding when there is no external via `isExpanded`
    @State private var _internalIsExpanded: Bool = false

    private var _isExpanded: Binding<Bool>
    {
        isExpanded ?? $_internalIsExpanded
    }

    let warnings: [TerminalOutput]
    
    init(
        isExpanded: Binding<Bool>? = nil,
        warnings: [TerminalOutput]
    ) {
        self.warnings = warnings
        self.isExpanded = isExpanded
    }

    var body: some View
    {
        DisclosureGroup(isExpanded: _isExpanded)
        {
            VStack(alignment: .leading, spacing: 5)
            {
                Text("label.warnings.dont-bother-cork-its-the-fault-of-someone-else")
                    .font(.subheadline)
                
                warnings.outputView
            }
        } label: {
            Text("label.warnings")
        }
        .betterDisclosureGroupStyle()
    }
}
