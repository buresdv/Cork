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
    @EnvironmentObject var servicesState: ServicesState
    
    let service: HomebrewService
    
    var body: some View
    {
        HStack(alignment: .center)
        {
            Spacer()
            
            Button
            {
                Task
                {
                    await servicesTracker.stopService(service, servicesState: servicesState)
                }
            } label: {
                Text("service.stop-\(service.name)")
            }
            .disabled(service.status != .started)
            
            Button
            {
                Task
                {
                    await servicesTracker.startService(service, servicesState: servicesState)
                }
            } label: {
                Text("service.start-\(service.name)")
            }
            .disabled(service.status == .scheduled || service.status == .started)
        }
        .padding()
    }
}
