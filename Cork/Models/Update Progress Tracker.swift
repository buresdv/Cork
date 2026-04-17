//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import CorkTerminalFunctions
import FactoryKit
import Foundation
import SwiftUI

@Observable
public class UpdateProgressTracker: @MainActor TerminalOutputStreamable
{
    public func insertOutput(_ output: CorkTerminalFunctions.TerminalOutput)
    {
        self.outputs.append(output)
    }

    public var outputs: [CorkTerminalFunctions.TerminalOutput] = .init()

    public var standardOutputs: [CorkTerminalFunctions.TerminalOutput] = .init()

    public var standardErrors: [CorkTerminalFunctions.TerminalOutput] = .init()

    public var isStreamedOutputExpanded: Bool = false

    @Injected(\.appConstants) @ObservationIgnored var appConstants

    var updateProgress: Float = 0
    var errors: [String] = .init()

    var realTimeOutput: [RealTimeTerminalLine] = .init()

    var currentStage: UpdateProcessStages.StandardCases?
}
