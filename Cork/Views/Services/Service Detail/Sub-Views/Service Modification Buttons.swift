//
//  Service Modification Buttons.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import SwiftUI

class ServiceModificationProgress: ObservableObject
{
    @Published var progress: Double = 0.1
}

struct ServiceModificationButtons: View
{
    @EnvironmentObject var servicesTracker: ServicesTracker
    @EnvironmentObject var servicesState: ServicesState

    let service: HomebrewService
    
    @ObservedObject private var serviceModificationProgress: ServiceModificationProgress = .init()
    
    @State private var isModifyingService: Bool = false
    
    @State private var isModifyingDestructively: Bool = false
    
    var body: some View
    {
        HStack(alignment: .center)
        {
            Spacer()
            
            Group
            {
                if service.status == .started || service.status == .scheduled
                {
                    Button
                    {
                        Task
                        {
                            isModifyingDestructively = true
                            
                            isModifyingService = true
                            
                            defer
                            {
                                isModifyingService = false
                            }
                            
                            await servicesTracker.stopService(service, servicesState: servicesState, serviceModificationProgress: serviceModificationProgress)
                        }
                    } label: {
                        HStack(alignment: .center)
                        {
                            if isModifyingService
                            {
                                ServiceModificationProgressView(serviceModificationProgress: serviceModificationProgress, isModifyingDestructively: isModifyingDestructively)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                            Text("service.stop-\(service.name)")
                        }
                    }
                }
                else
                {
                    Button
                    {
                        Task
                        {
                            isModifyingDestructively = false
                            
                            isModifyingService = true
                            
                            defer
                            {
                                isModifyingService = false
                            }
                            
                            await servicesTracker.startService(service, servicesState: servicesState, serviceModificationProgress: serviceModificationProgress)
                        }
                    } label: {
                        HStack(alignment: .center)
                        {
                            if isModifyingService
                            {
                                ServiceModificationProgressView(serviceModificationProgress: serviceModificationProgress, isModifyingDestructively: isModifyingDestructively)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                            Text("service.start-\(service.name)")
                        }
                    }
                }
            }
            .disabled(isModifyingService)
        }
        .padding()
        .animation(.easeIn, value: serviceModificationProgress.progress)
        .animation(.easeIn, value: isModifyingService)
    }
}

struct ServiceModificationProgressView: View
{
    @ObservedObject var serviceModificationProgress: ServiceModificationProgress
    
    let isModifyingDestructively: Bool
    
    var body: some View
    {
        Gauge(value: serviceModificationProgress.progress, in: 0.0...5.0)
        {
            
        }
        .gaugeStyle(MiniGaugeStyle(tint: isModifyingDestructively ? .red : .blue))
        .frame(width: 10, height: 10)
        .scaleEffect(0.35)
    }
}
