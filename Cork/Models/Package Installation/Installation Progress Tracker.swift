//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation
import CorkShared
import CorkModels
import CorkTerminalFunctions

@Observable
class InstallationProgressTracker: @MainActor TerminalOutputStreamable
{
    
    enum InstallationError: LocalizedError
    {
        enum ImplementedError: LocalizedError
        {
            enum FormulaInstallError: LocalizedError
            {
                enum ImplementedError: LocalizedError
                {
                    
                }
                
                case implemented(ImplementedError)
                case unimplelented(rawOutput: [TerminalOutput])
            }
            
            enum CaskInstallError: LocalizedError
            {
                enum ImplementedError: LocalizedError
                {
                    
                }
                
                case implemented(ImplementedError)
                case unimplelented(rawOutput: [TerminalOutput])
            }
            
            case couldNotSynchronizePackages(PackageSynchronizationError)
            case couldNotInstallFormula(FormulaInstallError)
            case couldNotInstallCask(CaskInstallError)
        }
        
        case implemented(ImplementedError)
        case unimplemented(rawOutput: [TerminalOutput])
    }
    
    enum FormulaInstallMatcher: TerminalOutputMatchable
    {
        enum StandardCases: TerminalOutputCase
        {
            case findingDependencies
            case downloadingDependencies
            case installingDependencies
            case downloadingPackage
            case installingPackage
            
            var patterns: [String]
            {
                switch self {
                case .findingDependencies:
                    ["Fetching dependencies"]
                case .downloadingDependencies:
                    <#code#>
                case .installingDependencies:
                    <#code#>
                case .downloadingPackage:
                    <#code#>
                case .installingPackage:
                    <#code#>
                }
            }
        }
        
        enum ErrorCases: TerminalOutputCase
        {
            case requiresPassword
        }
        
        enum IgnoredCases: TerminalOutputCase
        {
            
        }
        
        
    }
    
    func insertOutput(_ output: CorkTerminalFunctions.TerminalOutput) {
        self.outputs.append(output)
    }
    
    var outputs: [CorkTerminalFunctions.TerminalOutput] = .init()
    
    var standardOutputs: [CorkTerminalFunctions.TerminalOutput] = .init()
    
    var standardErrors: [CorkTerminalFunctions.TerminalOutput] = .init()
    
    var isStreamedOutputExpanded: Bool = false
    
    var packageBeingInstalled: PackageInProgressOfBeingInstalled = .init(package: .init(rawName: "", type: .formula, installedOn: nil, versions: [], url: nil, sizeInBytes: 0, downloadCount: nil), installationStage: .downloadingCask, packageInstallationProgress: 0)

    var numberOfPackageDependencies: Int = 0
    var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0
    
    private var installationProcess: Process?

    private var showRealTimeTerminalOutputs: Bool
    {
        UserDefaults.standard.bool(forKey: "showRealTimeTerminalOutputOfOperations")
    }
    
    deinit
    {
        cancel()
    }
    
    @discardableResult
    func cancel() -> Bool
    {
        guard let installationProcess else {return false}
        installationProcess.terminate()
        self.installationProcess = nil
        return true
    }
}
