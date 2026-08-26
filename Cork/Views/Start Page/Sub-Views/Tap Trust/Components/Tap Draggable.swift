//
//  Tap Draggable.swift
//  Cork
//
//  Created by David Bureš - P on 26.08.2026.
//

import SwiftUI
import CorkModels

struct TapDraggableView: View
{
    var tap: BrewTap
    
    var body: some View
    {
        GroupBox
        {
            Text(tap.name(withPrecision: .full))
                .padding()
        }
        .draggable(tap)
    }
}
