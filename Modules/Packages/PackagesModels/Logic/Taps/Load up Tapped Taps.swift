//
//  Load up Tapped Taps.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import Foundation
import CorkShared

public typealias BrewTaps = Set<Result<BrewTap, TapLoadingError>>

public extension TapTracker
{
    @MainActor
    func loadUpTappedTaps() async throws(TapLoadingError) -> BrewTaps
    {
        
        var finalAvailableTaps: [BrewTap] = .init()

        do
        {
            let contentsOfTapFolder: [URL] = try AppConstants.shared.tapPath.getContents(options: .skipsHiddenFiles)

            AppConstants.shared.logger.debug("Contents of tap folder: \(contentsOfTapFolder)")

            for tapRepoParentURL in contentsOfTapFolder
            {
                AppConstants.shared.logger.debug("Tap repo: \(tapRepoParentURL)")

                do
                {
                    let contentsOfTapRepoParent: [URL] = try tapRepoParentURL.getContents(options: .skipsHiddenFiles)

                    for repoURL in contentsOfTapRepoParent
                    {
                        let repoParentComponents: [String] = repoURL.pathComponents

                        let repoParentName: String = repoParentComponents.penultimate()!

                        let repoNameRaw: String = repoParentComponents.last!
                        let repoName: String = .init(repoNameRaw.dropFirst(9))

                        let fullTapName: String = "\(repoParentName)/\(repoName)"

                        AppConstants.shared.logger.info("Full tap name: \(fullTapName)")

                        finalAvailableTaps.append(try BrewTap(name: fullTapName))
                    }
                }
                catch let tapFolderReadingError
                {
                    throw TapLoadingError.couldNotReadTapFolderContents(errorDetails: tapFolderReadingError.localizedDescription)
                }
            }

            let nonLocalBasicTaps: BrewTaps = await withTaskGroup(of: Result<BrewTap, TapLoadingError>.self)
            { taskGroup in
                if finalAvailableTaps.filter({ $0.getCompleteTapName() == .init(repo: .homebrew, tapName: "core") }).isEmpty
                {
                    AppConstants.shared.logger.warning("Couldn't find homebrew/core in local taps")
                    
                    taskGroup.addTask
                    {
                        let isCoreAdded: Bool = await self.checkIfTapIsAdded(tapToCheck: "homebrew/core")
                        if isCoreAdded
                        {
                            AppConstants.shared.logger.info("homebrew/core is added, but not in local taps")
                            
                            do
                            {
                                return try .success(BrewTap(name: "homebrew/core"))
                            }
                            catch let tapLoadingError
                            {
                                return .failure(tapLoadingError as! TapLoadingError)
                            }
                        }
                        else
                        {
                            AppConstants.shared.logger.warning("homebrew/core is not added and not in local taps")
                            return .failure(.couldNotReadTapFolderContents(errorDetails: "homebrew/core is not added and not in local taps"))
                        }
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("Found homebrew/core in local taps")
                }

                if finalAvailableTaps.filter({ $0.getCompleteTapName() == .init(repo: .homebrew, tapName: "cask") }).isEmpty
                {
                    AppConstants.shared.logger.warning("Couldn't find homebrew/cask in local taps")
                    taskGroup.addTask
                    {
                        let isCaskAdded: Bool = await self.checkIfTapIsAdded(tapToCheck: "homebrew/cask")
                        if isCaskAdded
                        {
                            do
                            {
                                return try .success(BrewTap(name: "homebrew/cask"))
                            } catch let tapLoadingError {
                                return .failure(.couldNotReadTapFolderContents(errorDetails: tapLoadingError.localizedDescription))
                            }
                        }
                        else
                        {
                            AppConstants.shared.logger.warning("homebrew/cask is not added and not in local taps")
                            return .failure(.couldNotReadTapFolderContents(errorDetails: "homebrew/cask is not added and not in local taps"))
                        }
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("Found homebrew/cask in local taps")
                }

                var nonLocalBasicTapsInternal: BrewTaps = .init()

                for await tap in taskGroup
                {
                    if let tap = tap
                    {
                        nonLocalBasicTapsInternal.append(tap)
                    }
                }

                return nonLocalBasicTapsInternal
            }

            finalAvailableTaps.append(contentsOf: nonLocalBasicTaps)

            return finalAvailableTaps
        }
        catch let tapFolderReadingError
        {
            let shouldStrictlyCheckForHomebrewErrors: Bool = UserDefaults.standard.bool(forKey: "strictlyCheckForHomebrewErrors")
            
            if shouldStrictlyCheckForHomebrewErrors
            {
                throw TapLoadingError.couldNotAccessParentTapFolder(errorDetails: tapFolderReadingError.localizedDescription)
            }
            else
            {
                return [
                    .success(.homebrewCore),
                    .success(.homebrewCask)
                ]
            }
        }
    }

    private func checkIfTapIsAdded(tapToCheck _: String) async -> Bool
    {
        return true
    }
}
