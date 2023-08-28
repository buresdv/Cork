//
//  Download Data From URL.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation

enum DataDownloadingError: Error
{
    case invalidResponseCode, noDataReceived
}

func downloadDataFromURL(_ url: URL) async throws -> Data
{
    let session: URLSession = URLSession.shared
    
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
