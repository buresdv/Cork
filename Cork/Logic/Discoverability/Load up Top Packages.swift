//
//  Load up Top Packages.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation
import SwiftyJSON

enum URLEncodingError: Error
{
    case failedToEncodeEndpointURL
}
enum PackageParsingError: Error
{
    case couldNotParseHomebrewResponse
}

func loadUpTopPackages(numberOfDays: Int = 30, isCask: Bool, appState: AppState) async throws -> [TopPackage]
{
    
    var statsURL: URL?
    
    if !isCask
    {
        statsURL = URL(string: "https://formulae.brew.sh/api/analytics/install/homebrew-core/\(numberOfDays)d.json")!
    }
    else
    {
        statsURL = URL(string: "https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/\(numberOfDays)d.json")!
    }
    
    do
    {
        if let statsURL
        {
            let brewBackendResponse = try await downloadDataFromURL(statsURL)
            
            do
            {
                let parsedPackages = try await parseDownloadedTopPackageData(data: brewBackendResponse, isCask: isCask, numberOfDays: numberOfDays)
                
                return parsedPackages
            }
            catch let packageParsingError
            {
                AppConstants.logger.error("Failed while parsing top packages: \(packageParsingError, privacy: .public)")
                await appState.setCouldNotParseTopPackages()
                
                throw packageParsingError
            }
        }
        else
        {
            throw URLEncodingError.failedToEncodeEndpointURL
        }
    }
    catch let brewApiError as DataDownloadingError
    {
        switch brewApiError {
            case .invalidResponseCode:
                AppConstants.logger.warning("Received invalid response code from Brew")
                
                throw brewApiError
            case .noDataReceived:
                AppConstants.logger.warning("Received no data from Brew")
                
                throw brewApiError
                
            case .invalidURL:
                print("Invalid URL")
                
                throw brewApiError
        }
    }
}

private func parseDownloadedTopPackageData(data: Data, isCask: Bool, numberOfDays: Int) async throws -> [TopPackage]
{
    /// The magic number here is the result of 1000/30, a base limit for 30 days: If the user selects the number of days to be 30, only show packages with more than 1000 downloads
    let packageDownloadsCutoff: Int = 33 * numberOfDays
    
    AppConstants.logger.debug("Cutoff for package downloads: \(packageDownloadsCutoff, privacy: .public)")
    
    do
    {
        var packageTracker: [TopPackage] = .init()
        
        let parsedJSON: JSON = try await parseJSON(from: data)
        
        AppConstants.logger.debug("Parsed JSON, time to decode")
        
        let packageArray = parsedJSON["formulae"]
        
        for packageDefinition in packageArray
        {
            /// formulaInfo is a tuple of (String: JSON)
            /// First, we have to get the second element of the tuple (the JSON), then that is an array witg the formula info. However, there's only one element in it, so we choose it
            let packageInfo = packageDefinition.1.arrayValue[0]
            
            let packageInfoAccessor: String = isCask ? "cask" : "formula"
            
            let packageInstalledCount: Int = Int(packageInfo["count"].stringValue.replacingOccurrences(of: ",", with: "")) ?? 696969
            
            /// Immediately throw away any package that has fewer than 1000 downloads to save on computing power
            if packageInstalledCount > packageDownloadsCutoff
            {
                let packageName: String = packageInfo[packageInfoAccessor].stringValue
                
                packageTracker.append(TopPackage(packageName: packageName, packageDownloads: packageInstalledCount))
            }
            
        }
        
        return packageTracker
    }
    catch let JSONParsingError
    {
        AppConstants.logger.error("Failed while parsing JSON: \(JSONParsingError.localizedDescription, privacy: .public)")
        
        throw JSONParsingError
    }
}
