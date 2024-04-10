//
//  View - Disable animations.swift
//  Cork
//
//  Created by David Bureš on 08.04.2024.
//

import Foundation
import SwiftUI

extension View
{
    @ViewBuilder func allAnimationsDisabled() -> some View
    {
        self
            .transaction { transaction in
                transaction.animation = nil
            }
    }
}
