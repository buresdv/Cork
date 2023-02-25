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
func installPackage(installationProgressTracker: InstallationProgressTracker, brewData: BrewDataStorage) async throws -> TerminalOutput
{
    print("Installing package \(installationProgressTracker.packagesBeingInstalled[0].package.name)")

    var installationResult = TerminalOutput(standardOutput: "", standardError: "")

    var packageDependencies: [String] = .init()

    if !installationProgressTracker.packagesBeingInstalled[0].package.isCask
    {
        
        print("Package is Formula")
        
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

                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 1
                }
                else if outputLine.contains("Already downloaded") || outputLine.contains("Fetching \(outputLine.containsElementFromArray(packageDependencies))")
                {
                    print("Will fetch dependencies!")
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .fetchingDependencies
                    
                    installationProgressTracker.numberInLineOfPackageCurrentlyBeingFetched = installationProgressTracker.numberInLineOfPackageCurrentlyBeingFetched + 1
                    
                    print("Fetching dependency \(installationProgressTracker.numberInLineOfPackageCurrentlyBeingFetched) of \(packageDependencies.count)")
                    
                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + Double(Double(10) / (Double(3) * (Double(installationProgressTracker.numberOfPackageDependencies) * Double(5))))
                }
                else if outputLine.contains("Installing dependencies") || outputLine.contains("Installing \(installationProgressTracker.packagesBeingInstalled[0].package.name) dependency")
                {
                    print("Will install dependencies!")
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingDependencies

                    // Increment by 1 for each package that finished installing
                    installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled = installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled + 1
                    print("Installing dependency \(installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled) of \(packageDependencies.count)")

                    // TODO: Add a math formula for advancing the stepper
                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + Double(Double(10) / (Double(3) * Double(installationProgressTracker.numberOfPackageDependencies)))
                }
                else if outputLine.contains("Fetching \(installationProgressTracker.packagesBeingInstalled[0].package.name)") || outputLine.contains("Installing \(installationProgressTracker.packagesBeingInstalled[0].package.name)")
                {
                    print("Will install the package itself!")
                    installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingPackage

                    // TODO: Add a math formula for advancing the stepper
                    installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = Double(installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress) + Double( ( Double(10) - Double(installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress)) / Double(2))

                    print("Stepper value: \(Double(Double(10) / (Double(3) * Double(installationProgressTracker.numberOfPackageDependencies))))")
                }

                installationResult.standardOutput.append(outputLine)

                print("Current installation stage: \(installationProgressTracker.packagesBeingInstalled[0].installationStage)")

            case let .standardError(errorLine):
                print("Errored out: \(errorLine)")
            }
        }

        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 10
        
        installationProgressTracker.packagesBeingInstalled[0].installationStage = .finished
    
    }
    else
    {
        print("Package is Cask")
        print("Installing package \(installationProgressTracker.packagesBeingInstalled[0].package.name)")
        
        for await output in shell("/opt/homebrew/bin/brew", ["install", "--no-quarantine", installationProgressTracker.packagesBeingInstalled[0].package.name])
        {
            switch output
            {
                case let .standardOutput(outputLine):
                    print("Output line: \(outputLine)")
                    
                    if outputLine.contains("Downloading")
                    {
                        print("Will download Cask")
                        
                        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2
                        
                        installationProgressTracker.packagesBeingInstalled[0].installationStage = .downloadingCask
                        
                        
                    } else if outputLine.contains("Installing Cask")
                    {
                        print("Will install Cask")
                        
                        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2
                        
                        installationProgressTracker.packagesBeingInstalled[0].installationStage = .installingCask
                        
                        
                    } else if outputLine.contains("Moving App")
                    {
                        print("Moving App")
                        
                        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2
                        
                        installationProgressTracker.packagesBeingInstalled[0].installationStage = .movingCask
                    } else if outputLine.contains("Linking binary") {
                        
                        print("Linking Binary")
                        
                        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress + 2
                        
                        installationProgressTracker.packagesBeingInstalled[0].installationStage = .linkingCaskBinary
                        
                    } else if outputLine.contains("\(installationProgressTracker.packagesBeingInstalled[0].package.name) was successfully installed")
                    {
                        print("Finished installing app")
                        
                        installationProgressTracker.packagesBeingInstalled[0].installationStage = .finished
                        
                        installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress = 10
                        
                    }
                    
                case let .standardError(errorLine):
                    print("Line had error: \(errorLine)")
            }
        }
        
    }
    
    await synchronizeInstalledPackages(brewData: brewData)

    return installationResult
}
