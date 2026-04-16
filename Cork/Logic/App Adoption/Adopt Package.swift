//
//  Adopt Package.swift
//  Cork
//
//  Created by David Bureš - P on 07.10.2025.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import Foundation
import RegexBuilder

extension MassAppAdoptionView.MassAppAdoptionTacker
{
    @MainActor
    func adoptApp(
        _ appToAdopt: BrewPackagesTracker.AdoptableApp
    ) async -> AdoptionProcessResult
    {
        guard let caskToAdopt = appToAdopt.selectedAdoptionCandidateCaskName
        else
        {
            return .failure(
                .failedWithError(
                    failedAdoptionCandidate: appToAdopt,
                    error: .implemented(
                        .noAdoptionCandidateProvided(
                            appNameToAdopt: appToAdopt.appExecutable
                        )
                    )
                )
            )
        }

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", "--cask", "--adopt", caskToAdopt])

        adoptionProcess = process

        var consolidatedOutput: [TerminalOutput] = .init()

        for await output in stream
        {
            self.outputLines.append(.init(line: output))

            consolidatedOutput.append(output)
        }

        AppConstants.shared.logger.debug("""
        Finished mass adoption process for cask \(caskToAdopt) with this result:
        Output: \(consolidatedOutput.standardOutputs.joined())
        Error: \(consolidatedOutput.standardErrors.joined())
        """)

        if consolidatedOutput.standardErrors.isEmpty
        {
            AppConstants.shared.logger.info("Adoption process for cask \(caskToAdopt) was successful")

            return .success(appToAdopt)
        }
        else
        {
            AppConstants.shared.logger.error("Adoption process for cask \(caskToAdopt) failed. Will try to find the exact reason")

            enum PreciseErrorMatcher: TerminalOutputMatchable
            {
                typealias IgnoredCases = IgnoresNoOutputs

                enum ErrorCases: TerminalOutputCase
                {
                    case mismatchedVersions

                    var patterns: [String]
                    {
                        switch self
                        {
                        case .mismatchedVersions:
                            ["It seems the existing App is different from the one being installed"]
                        }
                    }
                }

                typealias StandardCases = MatchesNoStandardOutputs
            }

            let preciseErrorMatchingResult: BatchedTerminalOutputMatchResult = consolidatedOutput.match(as: PreciseErrorMatcher.self)
            
            print("Adoption precise matching result: \(preciseErrorMatchingResult)")

            if preciseErrorMatchingResult.errorOutputs.contains(.mismatchedVersions)
            {
                AppConstants.shared.logger.error("Error for adopting app \(appToAdopt.appExecutable) was because of mismatched versions - will try to match the exact versions")

                /// Get the appropriate line from the outputs
                if let terminalStringThatDescribesTheMismatchedVersion = consolidatedOutput.standardErrors.filter({ $0.contains("The bundle short version of") }).first
                {
                    
                    appConstants.logger.info("Found the right output for getting version mismatches: \(terminalStringThatDescribesTheMismatchedVersion)")
                    
                    
                    let expectedVersion = Reference(Substring.self)
                    let installedVersion = Reference(Substring.self)

                    let versionsMatchingRegex = Regex {
                        "short version of "
                        OneOrMore(.any)
                        " is "
                        Capture(as: expectedVersion) {
                            OneOrMore(.whitespace.inverted)
                        }
                        " but is "
                        Capture(as: installedVersion) {
                            OneOrMore(.whitespace.inverted)
                        }
                        " for "
                        OneOrMore(.any)
                    }
                    
                    if let matchedVersions = terminalStringThatDescribesTheMismatchedVersion.firstMatch(of: versionsMatchingRegex)
                    {
                        return .failure(
                            .failedWithError(
                                failedAdoptionCandidate: appToAdopt,
                                error: .implemented(
                                    .mismatchedVersions(
                                        .versionsKnown(
                                            expected: String(matchedVersions[expectedVersion]),
                                            installed: String(matchedVersions[installedVersion])
                                        )
                                    )
                                )
                            )
                        )
                    }
                    else
                    {
                        appConstants.logger.error("Failed while extracting versions for app adoption: Failed to encode matching regex")
                        /// Creating the REGEX failed for whatever reason
                        return .failure(
                            .failedWithError(
                                failedAdoptionCandidate: appToAdopt,
                                error: .implemented(
                                    .mismatchedVersions(
                                        .versionsUnknown(
                                            rawTerminalOutput: terminalStringThatDescribesTheMismatchedVersion
                                        )
                                    )
                                )
                            )
                        )
                    }
                }
                else
                {
                    appConstants.logger.info("Couldn't get the right output for getting version mismatches")
                    return .failure(
                        .failedWithError(
                            failedAdoptionCandidate: appToAdopt,
                            error: .implemented(
                                .mismatchedVersions(
                                    .versionsUnknown(rawTerminalOutput: consolidatedOutput.standardErrors.joined()
                                    )
                                )
                            )
                        )
                    )
                }
            }
            else
            {
                appConstants.logger.info("Could not determine the precise error for adopted package - will show a generic error")
                return .failure(
                    .failedWithError(
                        failedAdoptionCandidate: appToAdopt,
                        error: .unimplemented(rawTerminalOutput: consolidatedOutput.standardErrors.joined())
                    )
                )
            }
        }
    }
}
