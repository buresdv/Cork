//
//  Download Data From URL.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import CorkShared
import Foundation

enum DataDownloadingError: LocalizedError
{
    case invalidResponseCode(responseCode: Int?), noDataReceived, invalidURL, couldntExecuteRequest(error: String)

    var errorDescription: String?
    {
        switch self
        {
        case .invalidResponseCode(let responseCode):
            if let responseCode
            {
                return String(localized: "error.data-downloading.invalid-response.\(responseCode)")
            }
            else
            {
                return String(localized: "error.data-downloading.invalid-response.undetermined-response-code")
            }
        case .noDataReceived:
            return String(localized: "error.data-downloading.no-data-received")
        case .invalidURL:
            return String(localized: "error.data-downloading.invalid-url")
        case .couldntExecuteRequest(let error):
            return String(localized: "error.data-downloading.couldnt-execute-request.\(error)")
        }
    }
}

func downloadDataFromURL(_ url: URL, parameters: [URLQueryItem]? = nil) async throws(DataDownloadingError) -> Data
{
    let sessionConfiguration: URLSessionConfiguration = .default
    if AppConstants.shared.proxySettings != nil
    {
        sessionConfiguration.connectionProxyDictionary = [
            kCFNetworkProxiesHTTPEnable: 1,
            kCFNetworkProxiesHTTPPort: AppConstants.shared.proxySettings!.port,
            kCFNetworkProxiesHTTPProxy: AppConstants.shared.proxySettings!.host
        ] as [AnyHashable: Any]
    }

    let session: URLSession = .init(configuration: sessionConfiguration)

    var urlComponents: URLComponents? = .init(url: url, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = parameters
    guard let modifiedURL = urlComponents?.url
    else
    {
        throw DataDownloadingError.invalidURL
    }

    var request: URLRequest = .init(url: modifiedURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)

    request.httpMethod = "GET"

    do
    {
        let (data, response): (Data, URLResponse) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
        else
        {
            AppConstants.shared.logger.error("Received invalid networking response: \(response)")

            let responseCast: HTTPURLResponse? = response as? HTTPURLResponse
            throw DataDownloadingError.invalidResponseCode(responseCode: responseCast?.statusCode)
        }

        if data.isEmpty
        {
            throw DataDownloadingError.noDataReceived
        }

        return data
    }
    catch let requestExecutionError
    {
        throw .couldntExecuteRequest(error: requestExecutionError.localizedDescription)
    }
}
