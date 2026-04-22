//
//  Update Results List.swift
//  Cork
//
//  Created by David Bureš - P on 22.04.2026.
//

import Foundation
import SwiftUI
import CorkModels

struct UpdateResultsList: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    let updateErrors: [OutdatedPackagesTracker.IndividualPackageUpdatingError]
    
    var body: some View
    {
        DisclosureGroup("update-packages.failed.details-dropdown.label")
        {
            List(updateErrors)
            { updatingError in
                switch updatingError
                {
                case .implemented(let failedPackage, let error):
                    updateFailure_implementedError(failedPackage: failedPackage, error: error)
                case .unimplemented(let failedPackage, let rawOutput):
                    updateFailure_unimplementedError(failedPackage: failedPackage, rawTerminalOutput: rawOutput)
                }
            }
        }
    }
    
    @ViewBuilder
    func updateFailure_implementedError(
        failedPackage: OutdatedPackage,
        error: OutdatedPackagesTracker.IndividualPackageUpdatingError.ImplementedError
    ) -> some View {
        VStack(alignment: .leading, spacing: 2)
        {
            Text(failedPackage.package.name(withPrecision: .precise))
                .font(.body)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.multicolor)
        }
    }
    
    @ViewBuilder
    func updateFailure_unimplementedError(
        failedPackage: OutdatedPackage,
        rawTerminalOutput: String
    ) -> some View
    {
        HStack
        {
            Text(failedPackage.package.name(withPrecision: .precise))

            Spacer()

            Button
            {
                openWindow(id: .errorInspectorWindowID, value: rawTerminalOutput)
            } label: {
                Label("action.inspect-error", systemImage: "info.circle")
            }
            .labelStyle(.iconOnly)
        }
    }
}
