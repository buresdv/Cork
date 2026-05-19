//
//  Description Loadable.swift
//  CorkModels
//
//  Created by David Bureš - P on 19.05.2026.
//

import Foundation
import CorkTerminalFunctions
import CorkShared

public protocol DescriptionLoadable: Package
{
    @MainActor
    func loadDescription() async throws(BrewPackage.DescriptionLoadingError) -> String
}

public extension DescriptionLoadable
{
    @MainActor
    func loadDescription() async throws(BrewPackage.DescriptionLoadingError) -> String
    {
        let commandArguments: [String] = {
            switch self.type
            {
            case .formula:
                return ["desc", self.name(withPrecision: .precise)]
            case .cask:
                return ["desc", "--cask", self.name(withPrecision: .precise)]
            }
        }()
        
        let descriptionLookupResult: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, commandArguments)

        AppConstants.shared.logger.debug("Raw terminal output for \(self.type.description)  : \(descriptionLookupResult)")

        guard !descriptionLookupResult.isEmpty
        else
        {
            AppConstants.shared.logger.info("Package \(self.name(withPrecision: .precise), privacy: .public) has no description")

            throw .packageHasNoDescription
        }

        /// Make sure there is only one output, and get that output - it should be the description
        guard descriptionLookupResult.count == 1, let extractedOutput = descriptionLookupResult.first
        else
        {
            AppConstants.shared.logger.error("The description for package \(self.name(withPrecision: .precise), privacy: .public) doesn't have the correct format: \(descriptionLookupResult)")

            throw .unexpectedNumberOfOutputs(outputs: descriptionLookupResult)
        }

        let splitDescriptionLookupResult = extractedOutput.description.split(separator: ":")

        /// Check that the output got split into two parts - one with the package name repeated, the other with the actual description
        guard splitDescriptionLookupResult.count == 2
        else
        {
            AppConstants.shared.logger.error("Descripton for package \(self.name(withPrecision: .precise), privacy: .public) didn't have the expected character `:`.")

            throw .outputHasUnexpectedFormat(rawOutput: extractedOutput)
        }

        /// Get the last member of the array - should be the actual description, as everythig before the `:` character is just the name of the package repeated
        guard let extractedDescriptionFromSplitResult = splitDescriptionLookupResult.last?.trimmingCharacters(in: .whitespacesAndNewlines)
        else
        {
            AppConstants.shared.logger.error("Description for package \(self.name(withPrecision: .precise), privacy: .public) didn't have the expected last member")

            throw .outputHasUnexpectedFormat(rawOutput: extractedOutput)
        }

        print("Extracted output: \(extractedDescriptionFromSplitResult)")
        
        switch self.type
        {
        case .formula:
            print("Description lookup result: \(extractedDescriptionFromSplitResult)")

            return String(extractedDescriptionFromSplitResult)
            
        /// If the package is Cask, we have to do an additional split
        /// The remaining text looks like `(cask name) [Description]`, so we have to remove the parentheses
        case .cask:
            let removalRegex: Regex = /^\s*\([^)]+\)(?:,\s*\([^)]+\))*\s*/

            let finalDescription = extractedDescriptionFromSplitResult.replacing(removalRegex, with: "")

            return finalDescription
        }
    }
}
