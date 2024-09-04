//
//  Refresh Packages Intent.swift
//  Cork
//
//  Created by David Bureš on 26.05.2024.
//

import AppIntents
import Foundation
import CorkShared

enum RefreshIntentResult: String, AppEnum
{
    case refreshed
    case refreshedWithErrors
    case failed

    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "intent.refresh.result.display-representation")

    static var caseDisplayRepresentations: [RefreshIntentResult: DisplayRepresentation] = [
        .refreshed: DisplayRepresentation(title: "intent.refresh.result.refreshed"),
        .refreshedWithErrors: DisplayRepresentation(title: "intent.refresh.result.refreshed-with-errors"),
        .failed: DisplayRepresentation(title: "intent.refresh.result.failed")
    ]
}

struct RefreshPackagesIntent: AppIntent
{
    static var title: LocalizedStringResource = "intent.refresh.title"
    static var description: LocalizedStringResource = "intent.refresh.description"

    static var isDiscoverable: Bool = true
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<RefreshIntentResult>
    {
        let refreshCommandResult: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["update"])

        var refreshErrorWithoutBuggedHomebrewMessages: [String] = refreshCommandResult.standardError.components(separatedBy: "\n")
        refreshErrorWithoutBuggedHomebrewMessages = refreshErrorWithoutBuggedHomebrewMessages.filter { !$0.contains("Updating Homebrew") }

        if !refreshErrorWithoutBuggedHomebrewMessages.isEmpty
        {
            return .result(value: .refreshedWithErrors)
        }
        else
        {
            return .result(value: .refreshed)
        }
    }
}
