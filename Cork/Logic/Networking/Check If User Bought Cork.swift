//
//  Check If User Bought Cork.swift
//  Cork
//
//  Created by David Bureš on 18.03.2024.
//

import Foundation

enum CorkLicenseRetrievalError: Error
{
    case authorizationComplexNotEncodedProperly
}

func checkIfUserBoughtCork(for email: String) async throws -> Bool
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
    
    var urlComponents = URLComponents(url: AppConstants.authorizationEndpointURL, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [URLQueryItem(name: "requestedEmail", value: email)]
    guard let modifiedURL = urlComponents?.url else {
        throw DataDownloadingError.invalidURL
    }
    
    var request: URLRequest = URLRequest(url: modifiedURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
    
    request.httpMethod = "GET"
    
    let authorizationComplex = "\(AppConstants.licensingAuthorization.username):\(AppConstants.licensingAuthorization.passphrase)"
    
    guard let authorizationComplexAsData: Data = authorizationComplex.data(using: .utf8, allowLossyConversion: false)
    else
    {
        throw CorkLicenseRetrievalError.authorizationComplexNotEncodedProperly
    }
    
    request.addValue("Basic \(authorizationComplexAsData.base64EncodedString())", forHTTPHeaderField: "Authorization")
    
    let (_, response) = try await session.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
    {
        return true
    }
    else
    {
        return false
    }
}
