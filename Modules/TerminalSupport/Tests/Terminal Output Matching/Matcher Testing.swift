//
//  Matcher Testing.swift
//  CorkTests
//
//  Created by David Bureš - P on 05.04.2026.
//

import Testing
import CorkTerminalFunctions

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
            "Finished instaling Cask Cork",
            "Finished Instaling Cask Cork"
        ]
        
        var collectedResultsArray: [SimpleMatchingTest.StandardCases] = .init()
        
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
                
            } onUnimplementedOutput: {
                
            }

        }
        
        print("Results array: \(collectedResultsArray)")
        
        #expect(collectedResultsArray.contains(.installing) && collectedResultsArray.contains(.downloading) && collectedResultsArray.contains(.done))
    }
}
