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
    associatedtype DisplayableView: View
    associatedtype Argument
    
    /// View to describe the stage with
    @ViewBuilder
    func view(_ arguments: [Argument]) -> DisplayableView
}
