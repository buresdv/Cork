//
//  View - Conditional Modifiers.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation
import SwiftUI

extension View
{
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View
    {
        if condition
        {
            transform(self)
        }
        else
        {
            self
        }
    }
}
