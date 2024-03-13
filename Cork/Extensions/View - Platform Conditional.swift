//
//  View - Platform Conditional.swift
//  Cork
//
//  Created by David Bureš on 11.03.2024.
//

import Foundation
import SwiftUI

extension View
{
    func modify<T: View>(@ViewBuilder modifier: (Self) -> T) -> T
    {
        modifier(self)
    }
}
