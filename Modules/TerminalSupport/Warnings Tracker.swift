//
//  Warnings Tracker.swift
//  CorkShared
//
//  Created by David Bureš - P on 08.09.2026.
//

import Foundation
import Observation
import FactoryKit

@Observable
public class WarningsTracker
{
    private var capturedWarningsPrivate: Set<TerminalOutput>
    
    public var capturedWarnings: [TerminalOutput]
    {
        return self.capturedWarningsPrivate.sorted{ $0.timestamp < $1.timestamp }
    }
    
    public var hasWarnings: Bool
    {
        return !self.capturedWarningsPrivate.isEmpty
    }
    
    public init()
    {
        self.capturedWarningsPrivate = .init()
    }
    
    public func insertWarning(warningToInsert: TerminalOutput)
    {
        if !self.capturedWarningsPrivate.contains(where: { $0.description.contains(warningToInsert.description)})
        {
            self.capturedWarningsPrivate.insert(warningToInsert)
        }
        
    }
}

public extension Container
{
    var warningsTracker: Factory<WarningsTracker>
    {
        Factory(self)
        {
            WarningsTracker()
        }
        .singleton
    }
}

