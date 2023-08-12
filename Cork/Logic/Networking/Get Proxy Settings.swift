//
//  Get Proxy Settings.swift
//  Cork
//
//  Created by David Bureš on 12.08.2023.
//

import Foundation

enum ProxyRetrievalError: Error
{
    case couldNotGetProxyStatus, couldNotGetProxyHost, couldNotGetProxyPort
}

func getProxySettings() throws -> NetworkProxy?
{
    let proxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as? [String: Any]
    
    guard let httpProxyHost = proxySettings?[kCFNetworkProxiesHTTPProxy as String] as? String else {
        throw ProxyRetrievalError.couldNotGetProxyHost
    }
    guard let httpProxyPort = proxySettings?[kCFNetworkProxiesHTTPPort as String] as? Int else {
        throw ProxyRetrievalError.couldNotGetProxyPort
    }
    
    return NetworkProxy(host: httpProxyHost, port: httpProxyPort)
}
