//
//  Progressable.swift
//  CorkShared
//
//  Created by David Bureš - P on 29.04.2026.
//

import Foundation
import BetterProgress

/// Attach a ``Progress`` to a stage enum, or anything else
public protocol Progressable
{
    /// Optional ``Progress`` for this stage
    var progress: Progress? { get set }
    
    /// Parent for this stage's ``Progress``
    var parentProgress: Progress? { get set }
}
