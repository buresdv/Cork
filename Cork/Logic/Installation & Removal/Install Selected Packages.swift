//
//  Install Selected Packages.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import Foundation
import SwiftUI

enum InstallationError: Error
{
    case outputHadErrors
}

@MainActor
func installPackage(installationProgressTracker: InstallationProgressTracker, brewData _: BrewDataStorage) async throws -> TerminalOutput
{
    print("Installing package \(installationProgressTracker.packagesBeingInstalled[0].package.name)")

    var installationResult = TerminalOutput(standardOutput: "", standardError: "")
    
    var packageDependencies: [String] = .init()

    if !installationProgressTracker.packagesBeingInstalled[0].package.isCask
    {
        for await output in shell("/opt/homebrew/bin/brew", ["install", installationProgressTracker.packagesBeingInstalled[0].package.name])
        {
            switch output
            {
            case let .standardOutput(outputLine):

                print("Line out: \(outputLine)")

                    installationProgressTracker.packagesBeingInstalled[0].realTimeTerminalOutput?.append(outputLine)

                if outputLine.contains("Fetching dependencies")
                {
                    // First, we have to get a list of all the dependencies
                    let dependencyMatchingRegex: String = "(?<=\(installationProgressTracker.packagesBeingInstalled[0].package.name): ).*?(.*)"
                    var matchedDependencies = try regexMatch(from: outputLine, regex: dependencyMatchingRegex)
                    matchedDependencies = matchedDependencies.replacingOccurrences(of: " and", with: ",") // The last dependency is different, because it's preceded by "and" instead of "," so let's replace that "and" with "," so we can split it nicely
                    
                    print("Matched Dependencies: \(matchedDependencies)")
                    
                    packageDependencies = matchedDependencies.components(separatedBy: ", ") // Make the dependency list into an array
                    
                    print("Package Dependencies: \(packageDependencies)")
                    
                    print("Will fetch \(packageDependencies.count) dependencies!")
                    
                    installationProgressTracker.numberOfPackageDependencies = packageDependencies.count // Assign the number of dependencies to the tracker for the user to see
                    
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .fetchingDependencies
                    
                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 1
                }
                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(installationProgressTracker.packagesBeingInstalled[0].package.name) dependency")
                {
                    print("Will install dependencies!")
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingDependencies
                    
                    // Increment by 1 for each package that finished installing
                    installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled = installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled + 1
                    print("Installing dependency \(installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")
                    
                    // TODO: Add a math formula for advancing the stepper
                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + Double(( Double(10) / ( Double(3) * Double(installationProgressTracker.numberOfPackageDependencies))))
                }
                else if outputLine.contains("Fetching \(installationProgressTracker.packagesBeingInstalled[0].package.name)") || outputLine.contains("Installing \(installationProgressTracker.packagesBeingInstalled[0].package.name)")
                {
                    print("Will install the package itself!")
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingPackage
                    
                    // TODO: Add a math formula for advancing the stepper
                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + Double(( Double(10) / ( Double(3) * Double(installationProgressTracker.numberOfPackageDependencies))))
                    
                    print("Stepper value: \(Double(( Double(10) / ( Double(3) * Double(installationProgressTracker.numberOfPackageDependencies)))))")
                }

                installationResult.standardOutput.append(outputLine)
                    
                    print("Current installation stage: \(installationProgressTracker.packagesBeingInstalled[0].installationStage)")

            case let .standardError(errorLine):
                print("Errored out: \(errorLine)")
            }
        }

        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            installationProgressTracker.packagesBeingInstalled[0].installationStage = .finished
        }
        
    }
    else
    {
        /* async let installationResultComplete: TerminalOutput = await shell("/opt/homebrew/bin/brew", ["install", "--cask", package.name])

         print("Result for installing Cask \(package.name): \(await installationResultComplete)")

         if await installationResultComplete.standardError.contains("error")
         {
             throw InstallationError.outputHadErrors
         }
         else
         {
             installationResult = await installationResultComplete

             try withAnimation
             {
                 #warning("This fails to get the version for some reason. Figure out why")
                 brewData.installedCasks.append(BrewPackage(name: package.name, isCask: package.isCask, installedOn: package.installedOn, versions: [try extractPackageVersionFromTerminalOutput(terminalOutput: installationResult, packageBeingInstalled: package)], sizeInBytes: package.sizeInBytes))
             }
         } */
    }

    return installationResult
}
