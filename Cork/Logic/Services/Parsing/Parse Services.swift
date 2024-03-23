//
//  Parse Services.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation
import SwiftyJSON

func parseServices(rawOutput: String) throws -> Set<HomebrewService>
{
    var servicesTracker: Set<HomebrewService> = .init()
    
    do
    {
        let parsedJSON: JSON = try parseJSON(from: rawOutput)
        
        let servicesArray = parsedJSON.arrayValue
        
        for service in servicesArray
        {
            let serviceName: String = service["name"].stringValue
            let serviceStatus: ServiceStatus = ServiceStatus(service["status"].stringValue)
            
            let user: String? = service["user"].string
            
            let serviceURL: URL = service["file"].url ?? URL(string: "/")!
            
            let exitCode: Int? = service["exit_code"].int
            
            servicesTracker.insert(.init(name: serviceName, status: serviceStatus, user: user, location: serviceURL, exitCode: exitCode))
        }
        
        return servicesTracker
    }
    catch let parsingError
    {
        throw JSONError.parsingFailed
    }
}
