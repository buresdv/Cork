//
//  Refresh Packages Intent.swift
//  Cork
//
//  Created by David Bureš on 26.05.2024.
//

import AppIntents
import Foundation
import CorkShared
import CorkTerminalFunctions

enum RefreshIntentResult: String, AppEnum
{
    case refreshed
    case refreshedWithErrors
    case failed

    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "intent.refresh.result.display-representation")

    static let caseDisplayRepresentations: [RefreshIntentResult: DisplayRepresentation] = [
        .refreshed: DisplayRepresentation(title: "intent.refresh.result.refreshed"),
        .refreshedWithErrors: DisplayRepresentation(title: "intent.refresh.result.refreshed-with-errors"),
        .failed: DisplayRepresentation(title: "intent.refresh.result.failed")
    ]
}

struct RefreshPackagesIntent: AppIntent
{
    static let title: LocalizedStringResource = "intent.refresh.title"
    static let description: LocalizedStringResource = "intent.refresh.description"

    static let isDiscoverable: Bool = true
    static let openAppWhenRun: Bool = false

    func perform() async throws -> some ReturnsValue<RefreshIntentResult>
    {
        let refreshCommandResult: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["update"])

        if refreshCommandResult.containsErrors
        {
            return .result(value: .refreshedWithErrors)
        }
        else
        {
            return .result(value: .refreshed)
        }
    }
}
