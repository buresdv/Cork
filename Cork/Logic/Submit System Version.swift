//
//  Submit System Version.swift
//  Cork
//
//  Created by David Bureš on 31.03.2024.
//

import Foundation
import AppKit

func submitSystemVersion() async throws -> Void
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
    
    var isSelfCompiled: Bool = false
    #if SELF_COMPILED
    isSelfCompiled = true
    #endif
    
    var urlComponents = URLComponents(url: AppConstants.osSubmissionEndpointURL, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = await [
        URLQueryItem(name: "systemVersion", value: String(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)),
        URLQueryItem(name: "corkVersion", value: String(NSApplication.appVersion!)),
        URLQueryItem(name: "isSelfCompiled", value: String(isSelfCompiled))
    ]
    guard let modifiedURL = urlComponents?.url else {
        return
    }
    
    var request: URLRequest = URLRequest(url: modifiedURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
    
    request.httpMethod = "GET"
    
    let authorizationComplex = "\(AppConstants.licensingAuthorization.username):\(AppConstants.licensingAuthorization.passphrase)"
    
    guard let authorizationComplexAsData: Data = authorizationComplex.data(using: .utf8, allowLossyConversion: false)
    else
    {
        return
    }
    
    request.addValue("Basic \(authorizationComplexAsData.base64EncodedString())", forHTTPHeaderField: "Authorization")
    
    let (_, response) = try await session.data(for: request)
    
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
    {
        // If the user submitted their OS version, prevent the submission from happening again
        UserDefaults.standard.setValue(true, forKey: "hasSuccessfullySubmittedOSVersion")
    }
}
