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

func downloadDataFromURL(_ url: URL) async throws -> Data
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
    
    let request: URLRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else
    {
        throw DataDownloadingError.invalidResponseCode
    }
    
    if data.isEmpty
    {
        throw DataDownloadingError.noDataReceived
    }
    
    return data
}
