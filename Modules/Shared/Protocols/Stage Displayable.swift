//
//  Stage Displayable.swift
//  CorkShared
//
//  Created by David Bureš - P on 29.04.2026.
//

import Foundation
import SwiftUI

/// Attach a displayable view to an enum
public protocol StageDisplayable
{
    /// Text for the stage
    var stageDescription: LocalizedStringKey { get }
    
    /// Optional to display
    var view: (any View)? { get set }
}

public extension StageDisplayable
{
    var view: (any View)?
        {
            get { nil }
            set { }
        }
}
