//
//  Progressable.swift
//  CorkModels
//
//  Created by David Bureš - P on 28.04.2026.
//

import Foundation
import BetterProgress

public protocol Progressable: CaseIterable
{
    var progressForSelf: Progress { get set }
    
    var numberOfProgressSteps: Int { get set }
}
