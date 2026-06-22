//
//  Errored Out.swift
//  Cork
//
//  Created by David Bureš - P on 19.05.2026.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import SwiftUI

struct ErroredOutView: View
{
    let error: InstallationProgressTracker.InstallationError.ImplementedError
    let packageThatWasBeingInstalled: MinimalHomebrewPackage

    var body: some View
    {
        ComplexWithIcon(systemName: "xmark.seal")
        {
            HeadlineWithArbitraryContent(headline: "add-\(packageThatWasBeingInstalled.type.description)-\(packageThatWasBeingInstalled.name(withPrecision: .inlineFormatted)).error.title")
            {
                switch error
                {
                case .couldNotInstallFormula(let formulaInstallError):
                    switch formulaInstallError
                    {
                    case .implemented(let implementedFormulaInstallError):
                        VStack(alignment: .leading, spacing: 5)
                        {
                            if let errorDescription = implementedFormulaInstallError.errorDescription
                            {
                                Text(errorDescription)
                            }
                            else
                            {
                                Text("DEBUG: Unexpected missing string")
                            }

                            if let recoverySuggestion = implementedFormulaInstallError.recoverySuggestion
                            {
                                Text(recoverySuggestion)
                                    .foregroundStyle(.secondary)
                            }
                            else
                            {
                                Text("DEBUG: Unexpected missing string")
                            }
                        }
                    case .unimplelented(let rawOutputs):
                        unimplementedErrorView(rawOutputs: rawOutputs)
                    }

                    // MARK: - Cask Errors

                case .couldNotInstallCask(let caskInstallError):
                    switch caskInstallError
                    {
                    case .implemented(let implementedCaskInstallError):
                        VStack(alignment: .leading, spacing: 5)
                        {
                            if let errorDescription = implementedCaskInstallError.errorDescription
                            {
                                Text(errorDescription)
                            }
                            else
                            {
                                Text("DEBUG: Unexpected missing string")
                            }

                            if let recoverySuggestion = implementedCaskInstallError.recoverySuggestion
                            {
                                Text(recoverySuggestion)
                                    .foregroundStyle(.secondary)
                            }
                            else
                            {
                                Text("DEBUG: Unexpected missing string")
                            }
                        }
                    case .unimplelented(let rawOutputs):
                        unimplementedErrorView(rawOutputs: rawOutputs)
                    }

                case .couldNotSynchronizePackages:
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    func unimplementedErrorView(rawOutputs: [TerminalOutput]) -> some View
    {
        VStack(alignment: .leading)
        {
            Text("add-package.\(packageThatWasBeingInstalled.name(withPrecision: .general)).error.unimplemented-outputs.message")

            DisclosureGroup("add-package.error.unimplemented-outputs.dropdown.label")
            {
                List(rawOutputs)
                { rawOutput in
                    rawOutput.outputView
                }
                .listStyle(.bordered)
                .alternatingRowBackgrounds(.enabled)
                .frame(minHeight: 100)
            }
        }
    }
}
