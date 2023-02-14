//
//  Maintenance View.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

enum MaintenanceSteps
{
    case ready, maintenanceRunning, finished
}
enum MaintenanceProcessStages
{
    case standby, uninstallingOrphanedPackages, purgingCache
}

struct MaintenanceView: View {
    
    @Binding var isShowingSheet: Bool
    
    @State var maintenanceSteps: MaintenanceSteps = .ready
    @State var maintenanceProgressStages: MaintenanceProcessStages = .standby
    
    @State var shouldPurgeCache: Bool = true
    @State var shouldUninstallOrphans: Bool = true
    @State var shouldPerformHealthCheck: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)
        {
            switch maintenanceSteps {
            case .ready:
                SheetWithTitle(title: "Perform Brew maintenance") {
                    VStack(alignment: .leading, spacing: 10)
                    {
                        Form {
                            LabeledContent("Packages:") {
                                VStack(alignment: .leading)
                                {
                                    Toggle(isOn: $shouldUninstallOrphans) {
                                        Text("Uninstall orphaned packages")
                                    }
                                    Toggle(isOn: $shouldPurgeCache) {
                                        Text("Purge Brew cache")
                                    }
                                }
                            }
                            
                            LabeledContent("Other:") {
                                Toggle(isOn: $shouldPerformHealthCheck) {
                                    Text("Perform health check")
                                }
                            }
                        }
                        
                        HStack
                        {
                            DismissSheetButton(isShowingSheet: $isShowingSheet)
                            
                            Spacer()
                            
                            Button {
                                print("Start")
                                maintenanceSteps = .finished
                            } label: {
                                Text("Start Maintenance")
                            }
                            .keyboardShortcut(.defaultAction)

                        }
                    }
                }
                .padding()
                
            case .maintenanceRunning:
                ProgressView {
                    switch maintenanceProgressStages {
                        
                    case .standby:
                        Text("Firing up...")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    maintenanceProgressStages = .uninstallingOrphanedPackages
                                }
                            }
                        
                    case .uninstallingOrphanedPackages:
                        Text("Unistalling orphaned packages...")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    maintenanceProgressStages = .purgingCache
                                }
                            }
                        
                    case .purgingCache:
                        Text("Purging cache...")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    maintenanceProgressStages = .standby
                                    maintenanceSteps = .finished
                                }
                            }
                        
                    }
                }
                .padding()
                
            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet) {
                    ComplexWithIcon(systemName: "checkmark.seal") {
                        VStack(alignment: .leading)
                        {
                            Text("Maintenance finished")
                                .font(.headline)
                            
                            if shouldUninstallOrphans
                            {
                                Text("24 orphaned packages removed")
                            }
                            
                            if shouldPerformHealthCheck
                            {
                                Text("No errors found")
                            }
                            
                        }
                    }
                }
                .padding()
            }
    
        }
        
    }
}
