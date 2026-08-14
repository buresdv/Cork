//
//  Color - Variants.swift
//  Cork
//
//  Created by David Bureš - P on 12.08.2026.
//

import Foundation
import SwiftUI


public extension Color
{
    func lighter(by amount: CGFloat = 0.4) -> Self
    {
        if #available(macOS 15.0, *) {
            return self.mix(with: .white, by: amount)
        } else {
            return self
        }
    }

    func darker(by amount: CGFloat = 0.4) -> Self
    {
        if #available(macOS 15.0, *) {
            return self.mix(with: .black, by: amount)
        } else {
            return self
        }
    }

    func shadow(by amount: CGFloat = 0.3) -> Self
    {
        if #available(macOS 15.0, *) {
            return self.mix(with: .gray, by: amount)
        } else {
            return self
        }
    }
}
