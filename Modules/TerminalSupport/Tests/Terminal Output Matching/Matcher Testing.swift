//
//  Matcher Testing.swift
//  CorkTests
//
//  Created by David Bureš - P on 05.04.2026.
//

import CorkTerminalFunctions
import Testing

func streamTestingOutputs(
    outputs: [String],
    errors: [String]?
) -> AsyncStream<TerminalOutput>
{
    return AsyncStream<TerminalOutput>
    { continuation in
        for debugOutput in outputs
        {
            continuation.yield(.standardOutput(.init(rawOutput: debugOutput)))
        }

        if let errors
        {
            for debugError in errors
            {
                continuation.yield(.standardError(.init(rawOutput: debugError)))
            }
        }

        continuation.finish()
    }
}

@Suite("Terminal Output Matching")
struct MatcherTesting
{
    @Test("Test simple matching - no error cases or ignored strings")
    func testSimpleMatching() async throws
    {
        enum SimpleMatchingTest: TerminalOutputMatchable
        {
            typealias ErrorCases = ExpectsNoErrors

            typealias IgnoredCases = IgnoresNoOutputs

            enum StandardCases: TerminalOutputCase
            {
                case downloading
                case installing
                case done

                var patterns: [Regex<AnyRegexOutput>]
                {
                    switch self
                    {
                    case .downloading:
                        [.init(#/Downloading/#)]
                    case .installing:
                        [.init(#/Downloaded/#)]
                    case .done:
                        [.init(#/Finished installing/#)]
                    }
                }
            }
        }

        let testingOutputs: [String] = [
            "This will not match to anything",
            "Downloading Cask Cork",
            "Downloaded Cask Cork",
            "Finished installing Cask Cork",
            "Finished Installing Cask Cork"
        ]

        var collectedResultsArray: [SimpleMatchingTest.StandardCases] = .init()
        var errorsArray: [SimpleMatchingTest.ErrorCases] = .init()
        var unimplementedResultsArray: [TerminalOutput] = .init()

        for await debugOutput in streamTestingOutputs(outputs: testingOutputs, errors: nil)
        {
            debugOutput.match(as: SimpleMatchingTest.self)
            { standardOutputCase in
                switch standardOutputCase
                {
                case .downloading:
                    collectedResultsArray.append(.downloading)
                case .installing:
                    collectedResultsArray.append(.installing)
                case .done:
                    collectedResultsArray.append(.done)
                }
            } onErrorOutput: { errorOutputCase in
                errorsArray.append(errorOutputCase)
            } onUnimplementedOutput: { unimplementedCase in
                unimplementedResultsArray.append(unimplementedCase)
            }
        }

        print("Results array: \(collectedResultsArray)")

        #expect(collectedResultsArray == [.downloading, .installing, .done])
        #expect(errorsArray.isEmpty)
        #expect(unimplementedResultsArray.count == 2)
    }

    // MARK: - More complex matching

    @Test("Test more complex matching - Outputs with some errors")
    func testMoreComplexMatching() async throws
    {
        enum MoreComplexMatching: TerminalOutputMatchable
        {
            enum StandardCases: TerminalOutputCase
            {
                case downloading
                case installing
                case done

                var patterns: [Regex<AnyRegexOutput>]
                {
                    switch self
                    {
                    case .downloading:
                        [.init(#/Downloading/#)]
                    case .installing:
                        [.init(#/Installing/#), .init(#/Linking/#)]
                    case .done:
                        [.init(#/Installed/#), .init(#/Finished/#)]
                    }
                }
            }

            enum ErrorCases: TerminalOutputCase
            {
                case noResponseFromServer
                case noPermissions

                var patterns: [Regex<AnyRegexOutput>]
                {
                    switch self
                    {
                    case .noResponseFromServer:
                        [.init(#/Timed out/#)]
                    case .noPermissions:
                        [.init(#/Couldn't get permissions/#)]
                    }
                }
            }

            enum IgnoredCases: TerminalOutputCase
            {
                case cacheRefreshed

                var patterns: [Regex<AnyRegexOutput>]
                {
                    switch self
                    {
                    case .cacheRefreshed:
                        [.init(#/Refreshing cache/#)]
                    }
                }
            }
        }

        let testingOutputs: [String] = [
            "This line will not be matched",
            "Refreshing cache this line will also not be matched",
            "Downloading Cork",
            "Installing Cork",
            "Finished installing Cork",
            "Installed Cork"
        ]

        let testingErrors: [String] = [
            "This line will also not be matched",
            "Refreshing cache this line will also not be matched again",
            "Unimplemented error",
            "Timed out",
            "Couldn't get permissions"
        ]

        var collectedResultsArray: [MoreComplexMatching.StandardCases] = .init()
        var errorsArray: [MoreComplexMatching.ErrorCases] = .init()
        var unimplementedResultsArray: [TerminalOutput] = .init()

        for await output in streamTestingOutputs(outputs: testingOutputs, errors: testingErrors)
        {
            output.match(as: MoreComplexMatching.self)
            { matchedOutput in
                switch matchedOutput
                {
                case .downloading:
                    collectedResultsArray.append(.downloading)
                case .installing:
                    collectedResultsArray.append(.installing)
                case .done:
                    collectedResultsArray.append(.done)
                }
            } onErrorOutput: { matchedError in
                switch matchedError
                {
                case .noResponseFromServer:
                    errorsArray.append(.noResponseFromServer)
                case .noPermissions:
                    errorsArray.append(.noPermissions)
                }
            } onUnimplementedOutput: { unimplmenentedOutput in
                unimplementedResultsArray.append(unimplmenentedOutput)
            }
        }

        print("Results array: \(collectedResultsArray)")

        #expect(collectedResultsArray == [.downloading, .installing, .done, .done])
        #expect(errorsArray == [.noResponseFromServer, .noPermissions])
        #expect(unimplementedResultsArray.count == 3)
    }

    // MARK: - Live matching
}

@Suite("Adoptable App Output Matching")
struct AdoptableAppOutputMatching
{
    @Test("Test error parsing - mismatched app versions")
    func testErrorParsing() async throws
    {
        enum AdoptableAppOutputMatcher: TerminalOutputMatchable
        {
            typealias StandardCases = MatchesNoStandardOutputs

            enum ErrorCases: TerminalOutputCase
            {
                case mismatchedVersions

                var patterns: [Regex<AnyRegexOutput>]
                {
                    switch self
                    {
                    case .mismatchedVersions:
                        [.init(#/The bundle short version of .+ is .+ but is .+ for .+!/#)]
                    }
                }
            }

            enum IgnoredCases: TerminalOutputCase
            {
                case ignorableLine

                var patterns: [Regex<AnyRegexOutput>]
                {
                    switch self
                    {
                    case .ignorableLine:
                        [.init(#/This will be ignored/#)]
                    }
                }
            }
        }

        let testingOutputs: [String] = [
            "This will not be matched",
            "This will be ignored"
        ]

        let testingErrors: [String] = [
            "The bundle short version of /opt/homebrew/Caskroom/balenaetcher/2.1.4/balenaEtcher.app is 2.1.4 but is 2.1.2 for /Applications/balenaEtcher.app!",
            "This will be ignored as well"
        ]

        var collectedResultsArray: [AdoptableAppOutputMatcher.StandardCases] = .init()
        var errorsArray: [AdoptableAppOutputMatcher.ErrorCases] = .init()
        var unimplementedResultsArray: [TerminalOutput] = .init()

        for await output in streamTestingOutputs(outputs: testingOutputs, errors: testingErrors)
        {
            output.match(as: AdoptableAppOutputMatcher.self)
            { matchedOutput in
                collectedResultsArray.append(matchedOutput)
            } onErrorOutput: { matchedError in
                switch matchedError
                {
                case .mismatchedVersions:
                    errorsArray.append(.mismatchedVersions)
                }
            } onUnimplementedOutput: { unimplementedOutput in
                unimplementedResultsArray.append(unimplementedOutput)
            }
        }

        print("Results array: \(collectedResultsArray)")

        #expect(collectedResultsArray.isEmpty)
        #expect(errorsArray == [.mismatchedVersions])
        #expect(unimplementedResultsArray.count == 1)
    }
}
