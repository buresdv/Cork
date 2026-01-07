//
//  Mass Modifiable.swift
//  Cork
//
//  Created by David Bureš - P on 07.01.2026.
//

import Foundation
import SwiftUI

// TODO: Finish this protocol
/// A protocol for implementing buttons that mass-modify some data
///
/// Adds `Select All` and `Deselect All` buttons
protocol MassModifiable
{
    associatedtype SelectAllButton: View
    associatedtype DeselectAllButton: View
    
    var selectAllButton: SelectAllButton { get }
    var deselectAllButton: DeselectAllButton { get }
}

