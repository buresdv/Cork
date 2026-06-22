//
//  Update All Packages View.swift
//  Cork
//
//  Created by David Bureš - P on 24.04.2026.
//

import CorkModels
import CorkTerminalFunctions
import FactoryKit
import SwiftUI

struct UpdateAllPackagesView: View
{
    enum CompleteUpdatingError: Error
    {
        case containsUnexpectedOutputs([TerminalOutput])
    }

    @Environment(UpdateProgressTracker.self) var updateProgressTracker: UpdateProgressTracker
    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker

    @Observable
    final class FullUpdateStageTracker
    {
        var currentStage: UpdateProgressTracker.UpdateProcessMatcher.StandardCases

        public init()
        {
            self.currentStage = .downloading
        }
    }

    @State private var fullUpdateStageTracker: FullUpdateStageTracker = .init()

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ProgressView(updateProgressTracker.updateProgress)

            updateProgressTracker.streamedOutputsDisplay
        }
        .frame(maxWidth: .infinity)
        .task
        {
            do throws(Self.CompleteUpdatingError)
            {
                try await outdatedPackagesTracker.updatePackages(
                    updateProgressTracker: updateProgressTracker,
                    fullUpdateStageTracker: fullUpdateStageTracker
                )
                
                updateProgressTracker.updatingState = .finished
            }
            catch let completeUpdatingError
            {
                switch completeUpdatingError
                {
                case .containsUnexpectedOutputs(let unexpectedOutputs):
                    updateProgressTracker.updatingState = .completedWithUnexpectedOutputs(unimplementedOutputs: unexpectedOutputs)
                }
            }
        }
    }
}
