//
//  Parse Service Details.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import Foundation
import SwiftyJSON

func parseServiceDetails(rawOutput: String) throws -> ServiceDetails
{
    do
    {
        let parsedJSON: JSON = try parseJSON(from: rawOutput)
        
        let serviceDetailsObject = parsedJSON.arrayValue[0]
        
        let serviceIsloaded: Bool = serviceDetailsObject["loaded"].boolValue
        let serviceIsSchedulable: Bool = serviceDetailsObject["schedulable"].boolValue
        let servicePid: Int? = serviceDetailsObject["pid"].int
        
        let serviceRootDir: URL? = serviceDetailsObject["root_dir"].url
        let serviceLogPath: URL? = serviceDetailsObject["log_path"].url
        let serviceErrorLogPath: URL? = serviceDetailsObject["error_log_path"].url
        
        return ServiceDetails(loaded: serviceIsloaded, schedulable: serviceIsSchedulable, pid: servicePid, rootDir: serviceRootDir, logPath: serviceLogPath, errorLogPath: serviceErrorLogPath)
    }
    catch let parsingError
    {
        AppConstants.logger.error("Failed while parsing service details: \(parsingError.localizedDescription)")
        
        throw JSONError.parsingFailed
    }
}
