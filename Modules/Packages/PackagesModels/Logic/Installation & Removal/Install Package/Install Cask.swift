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
    ) async throws(InstallationError)
    {
        AppConstants.shared.logger.info("Package is Cask")
        AppConstants.shared.logger.debug("Installing package \(caskToInstall.name(withPrecision: .precise), privacy: .public)")

        let (stream, process): (AsyncStream<TerminalOutput>, Process) = shell(AppConstants.shared.brewExecutablePath, ["install", "--cask", caskToInstall.name(withPrecision: .precise)])
        installationProcess = process
        
        var consolidatedUnimplementedOutput: [TerminalOutput] = .init()
        var installError: InstallationError.ImplementedError.CaskInstallError?
        
        for await output in stream
        {
            print("Raw cask install output: \(output)")
            
            self.insertOutput(output)

            output.match(as: CaskInstallMatcher.self)
            { standardCase in
                
                self.installStage = .cask(standardCase)
                
                print("Matched install stage: \(standardCase)")
                
            } onErrorOutput: { errorCase in
                print("Matched error stage: \(errorCase)")
                
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
                print("Matched unimplemented stage")
                consolidatedUnimplementedOutput.append(unimplementedCase)
            }
        }
        
        print("Install errors: \(installError)")
        
        if let installError
        {
            print("Install process will throw error: \(installError)")
            
            throw .implemented(.couldNotInstallCask(installError))
        }
        
        if !consolidatedUnimplementedOutput.isEmpty
        {
            throw .implemented(.couldNotInstallCask(.unimplelented(rawOutput: consolidatedUnimplementedOutput)))
        }
        
        
    }
}
