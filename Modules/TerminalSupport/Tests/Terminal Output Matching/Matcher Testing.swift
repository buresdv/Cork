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
            continuation.yield(.standardOutput(debugOutput))
        }

        if let errors
        {
            for debugError in errors
            {
                continuation.yield(.standardError(debugError))
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

                var patterns: [String]
                {
                    switch self
                    {
                    case .downloading:
                        ["Downloading"]
                    case .installing:
                        ["Downloaded"]
                    case .done:
                        ["Finished installing"]
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

                var patterns: [String]
                {
                    switch self
                    {
                    case .downloading:
                        ["Downloading"]
                    case .installing:
                        ["Installing", "Linking"]
                    case .done:
                        ["Installed", "Finished"]
                    }
                }
            }

            enum ErrorCases: TerminalOutputCase
            {
                case noResponseFromServer
                case noPermissions

                var patterns: [String]
                {
                    switch self
                    {
                    case .noResponseFromServer:
                        ["Timed out"]
                    case .noPermissions:
                        ["Couldn't get permissions"]
                    }
                }
            }

            enum IgnoredCases: TerminalOutputCase
            {
                case cacheRefreshed

                var patterns: [String]
                {
                    switch self
                    {
                    case .cacheRefreshed:
                        ["Refreshing cache"]
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
    @Test func testErrorParsing() async throws
    {
        let output: [TerminalOutput] = [
            .standardError("The bundle short version of /opt/homebrew/Caskroom/balenaetcher/2.1.4/balenaEtcher.app is 2.1.4 but is 2.1.2 for /Applications/balenaEtcher.app!"),
            .standardOutput("This will not be matched"),
            .standardOutput("This will be ignored"),
            .standardError("This will be ignored as well")
        ]
        
        enum AdoptableAppOutputMatcher: TerminalOutputMatchable
        {
            typealias StandardCases = MatchesNoStandardOutputs
            
            enum ErrorCases: TerminalOutputCase
            {
                case mismatchedVersions
                
                var patterns: [String]
                {
                    switch self
                    {
                    case .mismatchedVersions:
                        ["The bundle short version of .+ is .+ but is .+ for .+!"]
                    }
                }
            }
            
            enum IgnoredCases: TerminalOutputCase
            {
                var patterns: [String]
                {
                    ["This will be ignored"]
                }
            }
        }
        
        let matchResult: BatchedTerminalOutputMatchResult = output.match(as: AdoptableAppOutputMatcher.self)
        
        #expect(matchResult.standardOutputs.isEmpty)
        #expect(matchResult.errorOutputs == [.mismatchedVersions])
        #expect(matchResult.unimplementedOutputs.count == 1)
    }
}
