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
    let corkVersion: String = await String(NSApplication.appVersion!)
    
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
    if ProcessInfo.processInfo.environment["SELF_COMPILED"] == "true"
    {
        isSelfCompiled = true
    }
    
    var urlComponents = URLComponents(url: AppConstants.osSubmissionEndpointURL, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [
        URLQueryItem(name: "systemVersion", value: String(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)),
        URLQueryItem(name: "corkVersion", value: corkVersion),
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
        #if DEBUG
        AppConstants.logger.debug("Sucessfully submitted system version")
        #endif
        
        UserDefaults.standard.setValue(corkVersion, forKey: "lastSubmittedCorkVersion")
    }
}
