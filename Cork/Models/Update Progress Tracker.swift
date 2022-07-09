//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

enum UpdateStages: String {
    case notDoingAnything = ""
    case updating = "Pulling updates..."
    case upgrading = "Applying updates... this might take some time"
}

class UpdateProgressTracker: ObservableObject {
    @Published var updateProgress: Float = 0
    @Published var updateStage: UpdateStages = .notDoingAnything
    @Published var showUpdateSheet: Bool = false
}
