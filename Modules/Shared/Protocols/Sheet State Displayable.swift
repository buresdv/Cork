//
//  Sheet State Displayable.swift
//  CorkShared
//
//  Created by David Bureš - P on 23.04.2026.
//

import Foundation
import SwiftUI

/// Protocol for associating buttons with views in sheets
public protocol SheetButtonDisplayable
{
    /// Buttons that should be shows for each state
    var buttonsForState: any ToolbarContent { get set }
}
