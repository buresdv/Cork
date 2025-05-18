//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

@Observable
class UpdateProgressTracker
{
    var updateProgress: Float = 0
    var errors: [String] = .init()

    var realTimeOutput: [RealTimeTerminalLine] = .init()
}
