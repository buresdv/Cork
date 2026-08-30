//
//  Interaction Highlightable.swift
//  CorkModels
//
//  Created by David Bureš - P on 25.08.2026.
//

import Foundation

/// Whether this element can have any sort of highlighting that makes it easier to see it as an element that can be interacted with
public protocol InteractionHighlightable
{
    var isExemptFromHighlighting: Bool { get }
}
