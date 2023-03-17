//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

class UpdateProgressTracker: ObservableObject
{
    @Published var updateProgress: Float = 0
    @Published var errors: [String] = .init()
}
