//
//  Homebrew Services View.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI

struct HomebrewServicesView: View
{
    @Environment(\.controlActiveState) var controlActiveState: ControlActiveState
    
    @EnvironmentObject private var appDelegate: AppDelegate

    @StateObject var servicesTracker: ServicesTracker = .init()
    @StateObject var servicesState: ServicesState = .init()

    @State private var hasTriedToUpdateHomebrewThroughCork: Bool = false
    @State private var isShowingHomebrewUpdateInstructions: Bool = false

    @State private var navigationTargetLocal: NavigationTargetServices?

    var body: some View
    {
        NavigationSplitView
        {
            ServicesSidebarView()
                .navigationDestination(for: HomebrewService.self)
                { service in
                    ServiceDetailView(service: service)
                        .id(service.id)
                }
        } detail: {
            NavigationStack
            {
                ServicesStartPage()
            }
        }
        .environmentObject(servicesTracker)
        .environmentObject(servicesState)
        .navigationTitle("services.title")
        .navigationSubtitle(servicesState.isLoadingServices ? "service-status-page.loading" : "services.count.\(servicesTracker.services.count)")
        .toolbar
        {
            LoadServicesButton()
        }
        .task(priority: .userInitiated)
        {
            await loadServices()
        }
        .alert(isPresented: $servicesState.isShowingError, error: servicesState.errorToShow)
        { error in
            switch error
            {
            case .couldNotLoadServices(error: ""):
                EmptyView()
            case .couldNotLoadServices:
                LoadServicesButton()
                dismissAlertButton
            case .couldNotStartService:
                EmptyView()
            case .couldNotStopService:
                EmptyView()
            case .couldNotSynchronizeServices:
                EmptyView()
            case .homebrewOutdated:
                if !hasTriedToUpdateHomebrewThroughCork
                {
                    Button
                    {
                        appDelegate.appState.isShowingUpdateSheet = true
                        hasTriedToUpdateHomebrewThroughCork = true
                    } label: {
                        Text("action.update-homebrew")
                    }
                }
                else
                {
                    Button
                    {
                        isShowingHomebrewUpdateInstructions = true
                    } label: {
                        Text("action.update-homebrew.terminal")
                    }
                }

                dismissAlertButton
            }
        } message: { error in
            if let recoverySuggestion = error.recoverySuggestion
            {
                Text(recoverySuggestion)
            }
        }
        .confirmationDialog("state.update-homebrew.terminal.title", isPresented: $isShowingHomebrewUpdateInstructions)
        {
            Button
            {
                "brew update".copyToClipboard()

                openTerminal()

                NSApp.terminate(nil)
            } label: {
                Text("action.open-terminal")
            }
        } message: {
            Text("state.update-homebrew.terminal.message")
        }
    }
    
    @ViewBuilder
    var dismissAlertButton: some View
    {
        Button
        {
            servicesState.dismissError()
        } label: {
            Text("action.close")
        }
    }
    
    // This function is a duplicate of the function in `LoadServicesButton`
    private func loadServices() async
    {
        print("Control active state: \(controlActiveState)")
        
        if servicesState.isLoadingServices == false
        {
            servicesState.isLoadingServices = true
        }
        
        defer
        {
            servicesState.isLoadingServices = false
        }
        
        do
        {
            try await servicesTracker.loadServices()
        }
        catch let servicesLoadingError as HomebrewServiceLoadingError
        {
            switch servicesLoadingError
            {
                case .homebrewOutdated:
                    servicesState.showError(.homebrewOutdated)
                default:
                    servicesState.showError(.couldNotLoadServices(error: servicesLoadingError.localizedDescription))
            }
        }
        catch let servicesLoadingError
        {
            servicesState.showError(.couldNotLoadServices(error: servicesLoadingError.localizedDescription))
        }
    }
}
