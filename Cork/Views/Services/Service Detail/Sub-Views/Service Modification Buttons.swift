//
//  Service Modification Buttons.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import SwiftUI

struct ServiceModificationButtons: View
{
    
    @EnvironmentObject var servicesTracker: ServicesTracker
    
    let service: HomebrewService
    
    var body: some View
    {
        HStack(alignment: .center)
        {
            Button
            {
                Task
                {
                    await servicesTracker.stopService(service)
                }
            } label: {
                Text("service.stop-\(service.name)")
            }
            
            Button
            {
                Task
                {
                    do
                    {
                        try await servicesTracker.startService(service)
                    }
                    catch let serviceStartingError as ServiceStartingError
                    {
                        switch serviceStartingError
                        {
                            case .couldNotStartService(let serviceStartingError):
                                AppConstants.logger.error("Could not start service: \(serviceStartingError)")
                        }
                    }
                }
            } label: {
                Text("service.start-\(service.name)")
            }
        }
        .padding()
    }
}
