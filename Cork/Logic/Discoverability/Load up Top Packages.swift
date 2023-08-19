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

func loadUpTopPackages(numberOfDays: Int = 30, isCask: Bool, appState: AppState) async throws -> Void
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
                let parsedPackages = try await parseDownloadedTopPackageData(data: brewBackendResponse, isCask: isCask)
            }
            catch let packageParsingError
            {
                print("Failed while parsing top packages: \(packageParsingError)")
                appState.fatalAlertType = .couldNotParseTopPackages
                appState.isShowingFatalError = true
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
                print("Received invalid response code from Brew")
            case .noDataReceived:
                print("Received no data from Brew")
        }
    }
}

private func parseDownloadedTopPackageData(data: Data, isCask: Bool) async throws -> [TopPackage]
{
    do
    {
        var packageTracker: [TopPackage] = .init()
        
        let parsedJSON: JSON = try await parseJSON(from: data)
        
        print("Parsed JSON, time to decode")
        
        let packageArray = parsedJSON["formulae"]
        
        for packageDefinition in packageArray
        {
            /// formulaInfo is a tuple of (String: JSON)
            /// First, we have to get the second element of the tuple (the JSON), then that is an array witg the formula info. However, there's only one element in it, so we choose it
            let packageInfo = packageDefinition.1.arrayValue[0]
            
            let packageInfoAccessor: String = isCask ? "cask" : "formula"
            
            let packageInstalledCount: Int = Int(packageInfo["count"].stringValue.replacingOccurrences(of: ",", with: "")) ?? 696969
            
            /// Immediately throw away any package that has fewer than 1000 downloads to save on computing power
            if packageInstalledCount > 1000
            {
                let packageName: String = packageInfo[packageInfoAccessor].stringValue
                
                print("Package \(packageName) has \(packageInstalledCount) installations")
                
                packageTracker.append(TopPackage(packageName: packageName, packageDownloads: packageInstalledCount))
            }
            
        }
        
        return packageTracker
    }
    catch let JSONParsingError
    {
        print("Failed while parsing JSON: \(JSONParsingError.localizedDescription)")
        
        throw JSONParsingError
    }
}

private func sortDownloadedTopPackages(topPackages: [TopPackage]) async -> [TopPackage]?
{
    return nil
}
