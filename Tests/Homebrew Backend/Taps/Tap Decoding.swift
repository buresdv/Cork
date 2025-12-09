import Testing
import Foundation
import CorkShared
import CorkModels
import CorkTerminalFunctions

@Suite("Tap Decoding")
struct TapDecodingTest
{
    @Test("Decode Simple Tap JSON")
    func decodeSimpleTap() async throws
    {
        let demoData: String = """
[
  {
    "name": "marsanne/cask",
    "user": "marsanne",
    "repo": "cask",
    "path": "/opt/homebrew/Library/Taps/marsanne/homebrew-cask",
    "installed": true,
    "official": false,
    "formula_names": [

    ],
    "cask_tokens": [
      "marsanne/cask/cork",
      "marsanne/cask/virustotal"
    ],
    "formula_files": [

    ],
    "cask_files": [
      "/opt/homebrew/Library/Taps/marsanne/homebrew-cask/Casks/cork.rb",
      "/opt/homebrew/Library/Taps/marsanne/homebrew-cask/Casks/virustotal.rb"
    ],
    "command_files": [

    ],
    "remote": "https://github.com/marsanne/homebrew-cask",
    "custom_remote": false,
    "private": false
  }
]
"""
        guard let tapInfoAsData: Data = demoData.data(using: .utf8) else
        {
            fatalError("Couldn't convert the demo data from String to Data - the testing environment is fucked")
        }
        
        guard let decodedTapInfo: TapInfo = try? await .init(from: tapInfoAsData) else
        {
            fatalError("Couldn't init the TapInfo struct from the provided data")
        }
        
        #expect(decodedTapInfo.name == "marsanne/cask")
        #expect(decodedTapInfo.user == "marsanne")
        #expect(decodedTapInfo.installed == true)
        #expect(decodedTapInfo.path.absoluteString == "/opt/homebrew/Library/Taps/marsanne/homebrew-cask")
        #expect(decodedTapInfo.caskTokens.count == 2)
        #expect(decodedTapInfo.caskFiles?.count == 2)
    }

    @Test("Decode Core Tap")
    func decodeDefaultCoreTap() async throws
    {
        let decodedTapInfo = await parseTapInfoForSpeficiedTap(tapName: "homebrew/core")
        
        #expect(decodedTapInfo != nil)
    }

    @Test("Decode Cask Tap")
    func decodeCaskTap() async throws
    {
        let decodedTapInfo = await parseTapInfoForSpeficiedTap(tapName: "homebrew/cask")
        
        #expect(decodedTapInfo != nil)
    }
    
    private func parseTapInfoForSpeficiedTap(tapName: String) async -> TapInfo?
    {
        let coreTapRawOutput: String = await shell(AppConstants.shared.brewExecutablePath, ["tap-info", "--json", tapName]).standardOutput
        
        guard let tapInfoAsData: Data = coreTapRawOutput.data(using: .utf8) else
        {
            fatalError("Couldn't convert the demo data from String to Data - the testing environment is fucked")
        }
        
        return try? await .init(from: tapInfoAsData)
    }
}
