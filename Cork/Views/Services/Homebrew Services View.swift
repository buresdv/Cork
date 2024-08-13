//
//  Homebrew Services View.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI

struct HomebrewServicesView: View
{
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(\.controlActiveState) var controlActiveState

    @StateObject var servicesTracker: ServicesTracker = .init()
    @StateObject var servicesState: ServicesState = .init()

    @State private var hasTriedToUpdateHomebrewThroughCork: Bool = false
    @State private var isShowingHomebrewUpdateInstructions: Bool = false

    var activeServices: Set<HomebrewService>
    {
        return servicesTracker.services.filter { $0.status == .scheduled || $0.status == .started }
    }

    var unknownServices: Set<HomebrewService>
    {
        return servicesTracker.services.filter { $0.status == .unknown }
    }

    var erroredOutServices: Set<HomebrewService>
    {
        return servicesTracker.services.filter { $0.status == .error }
    }

    var inactiveServices: Set<HomebrewService>
    {
        return servicesTracker.services.subtracting(activeServices).subtracting(unknownServices).subtracting(erroredOutServices)
    }

    var body: some View
    {
        NavigationSplitView
        {
            ServicesSidebarView()
        } detail: {
            if servicesState.isLoadingServices
            {
                ProgressView("service-status-page.loading")
            }
            else
            {
                if servicesTracker.services.isEmpty
                {
                    if #available(macOS 14.0, *)
                    {
                        ContentUnavailableView(label: {
                            Label("service-status-page.no-services-found", systemImage: "magnifyingglass")
                        }, description: {}, actions: {
                            loadServicesButton
                                .labelStyle(.titleOnly)
                        })
                    }
                    else
                    {
                        Text("service-status-page.no-services-found")
                    }
                }
                else
                {
                    FullSizeGroupedForm
                    {
                        Section
                        {
                            if activeServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.play"), title: "service-status-page.active-services-\(activeServices.count)", mainText: "service-status-page.active-services.description", animateNumberChanges: true)
                            }

                            if erroredOutServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.trianglebadge.exclamationmark"), title: "service-status-page.errored-out-services-\(erroredOutServices.count)", mainText: "service-status-page.errored-out-services.description", animateNumberChanges: true)
                            }

                            if inactiveServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.pause"), title: "service-status-page.inactive-services-\(inactiveServices.count)", mainText: "service-status-page.inactive-services.description", animateNumberChanges: true)
                            }

                            if unknownServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.questionmark"), title: "service-status-page.unknown-services-\(unknownServices.count)", mainText: "service-status-page.unknown-services.description", animateNumberChanges: true)
                            }
                        } header: {
                            Text("service-status-page.title")
                                .font(.title)
                        }
                    }
                }
            }
        }
        .environmentObject(servicesTracker)
        .environmentObject(servicesState)
        .navigationTitle("services.title")
        .navigationSubtitle(servicesState.isLoadingServices ? "service-status-page.loading" : "services.count.\(servicesTracker.services.count)")
        .toolbar
        {
            loadServicesButton
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
            case .couldNotLoadServices(error: let error):
                loadServicesButton
                dismissAlertButton
            case .couldNotStartService(offendingService: let offendingService, errorThrown: let errorThrown):
                EmptyView()
            case .couldNotStopService(offendingService: let offendingService, errorThrown: let errorThrown):
                EmptyView()
            case .couldNotSynchronizeServices(errorThrown: let errorThrown):
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
    var loadServicesButton: some View
    {
        Button
        {
            Task(priority: .userInitiated)
            {
                await loadServices()
            }
        } label: {
            Label("action.reload-services", systemImage: "arrow.clockwise")
                .help("action.reload-services")
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

    func loadServices() async
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
