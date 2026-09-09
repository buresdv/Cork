//
//  Homebrew Warning Dropdown.swift
//  Cork
//
//  Created by David Bureš - P on 01.09.2026.
//

import CorkTerminalFunctions
import FactoryKit
import SwiftUI

struct HomebrewWarningsDropdown: View
{
    @InjectedObservable(\.warningsTracker) var warningsTracker: WarningsTracker

    /// Optional external binding
    var isExpanded: Binding<Bool>? = nil

    /// Internal binding when there is no external one
    @State private var _internalIsExpanded: Bool = false

    private var _isExpanded: Binding<Bool>
    {
        isExpanded ?? $_internalIsExpanded
    }

    init(
        isExpanded: Binding<Bool>? = nil,
    )
    {
        self.isExpanded = isExpanded
    }

    var body: some View
    {
        DisclosureGroup(isExpanded: _isExpanded)
        {
            warningsTracker.capturedWarnings.outputView
        } label: {
            Text("label.warnings")
        }
        .betterDisclosureGroupStyle()
    }
}
