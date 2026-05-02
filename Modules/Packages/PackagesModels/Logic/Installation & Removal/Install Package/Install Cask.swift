//
//  Install Cask.swift
//  Cork
//
//  Created by David Bureš on 28.04.2026.
//

import CorkShared
import CorkTerminalFunctions
import Foundation

extension InstallationProgressTracker
{
    @MainActor
    func installCask(
        _ caskToInstall: MinimalHomebrewPackage
    ) async throws(InstallationError.ImplementedError.CaskInstallError)
    {
        AppConstants.shared.logger.info("Package is Cask")
        AppConstants.shared.logger.debug("Installing package \(caskToInstall.name(withPrecision: .precise), privacy: .public)")

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", caskToInstall.name(withPrecision: .precise)])
        installationProcess = process
        
        var consolidatedUnimplementedOutput: [TerminalOutput] = .init()
        var installError: InstallationError.ImplementedError.CaskInstallError?
        
        for await output in stream
        {
            self.insertOutput(output)

            output.match(as: CaskInstallMatcher.self) { standardCase in
                
                self.installStage = .cask(standardCase)
                
                print("Matched install stage: \(standardCase)")
                
            } onErrorOutput: { errorCase in
                switch errorCase
                {
                case .requiresSudoPassword:
                    installError = .implemented(.requiresSudoPassword)
                case .binaryAlreadyExists:
                    installError = .implemented(.binaryAlreadyExists)
                case .wrongArchitecture:
                    installError = .implemented(.wrongArchitecture)
                }
            } onUnimplementedOutput: { unimplementedCase in
                consolidatedUnimplementedOutput.append(unimplementedCase)
            }

            installationProcess?.terminate()
            break
        }
        
        if let installError
        {
            throw installError
        }
        
        if !consolidatedUnimplementedOutput.isEmpty
        {
            throw .implemented(.containsUnexpectedOutputs(rawOutput: consolidatedUnimplementedOutput))
        }
    }
}
