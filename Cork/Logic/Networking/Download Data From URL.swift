//
//  Download Data From URL.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation

enum DataDownloadingError: Error
{
    case invalidResponseCode, noDataReceived, invalidURL
}

func downloadDataFromURL(_ url: URL, parameters: [URLQueryItem]? = nil) async throws -> Data
{
    
    let sessionConfiguration = URLSessionConfiguration.default
    if AppConstants.proxySettings != nil
    {
        sessionConfiguration.connectionProxyDictionary = [
            kCFNetworkProxiesHTTPEnable: 1,
            kCFNetworkProxiesHTTPPort: AppConstants.proxySettings!.port,
            kCFNetworkProxiesHTTPProxy: AppConstants.proxySettings!.host
        ] as [AnyHashable: Any]
    }
    
    let session: URLSession = URLSession(configuration: sessionConfiguration)
    
    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = parameters
    guard let modifiedURL = urlComponents?.url else {
        throw DataDownloadingError.invalidURL
    }
    
    var request: URLRequest = URLRequest(url: modifiedURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
    
    request.httpMethod = "GET"
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else
    {
        AppConstants.logger.error("Received invalid networking response: \(response)")
        throw DataDownloadingError.invalidResponseCode
    }
    
    if data.isEmpty
    {
        throw DataDownloadingError.noDataReceived
    }
    
    return data
}

