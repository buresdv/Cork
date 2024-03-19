//
//  Start Page.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

struct StartPage: View
{
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var availableTaps: AvailableTaps

    @EnvironmentObject var appState: AppState

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @State private var isOutdatedPackageDropdownExpanded: Bool = false
    
    @State private var dragOver: Bool = false
    
    @State private var isShowingTemporaryLicensingSheet: Bool = false
    @State private var emailToCheck: String = ""
    
    @State private var isEmailValid: Bool?
    
    @State private var isCheckingEmail: Bool = false
    
    var body: some View
    {
        VStack
        {
            if appState.isLoadingFormulae && appState.isLoadingCasks || availableTaps.addedTaps.isEmpty
            {
                ProgressView("start-page.loading")
            }
            else
            {
                VStack
                {
                    FullSizeGroupedForm
                    {
                        Section
                        {
                            OutdatedPackagesBox(isOutdatedPackageDropdownExpanded: $isOutdatedPackageDropdownExpanded)
                                .transition(.move(edge: .top))
                                .animation(.easeIn, value: appState.isCheckingForPackageUpdates)
                        } header: {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Text("start-page.status")
                                    .font(.title)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                
                                Button
                                {
                                    NSWorkspace.shared.open(URL(string: "https://blog.corkmac.app/p/upcoming-changes-to-the-install-process")!)
                                } label: {
                                    Text("start-page.upcoming-changes")
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1)
                                        .foregroundColor(.white)
                                        .background(.blue)
                                        .clipShape(.capsule)
                                }
                                .buttonStyle(.plain)
                                
                                Button
                                {
                                    isShowingTemporaryLicensingSheet.toggle()
                                } label: {
                                    Text("temporary-licensing.show-sheet")
                                }
                            }
                        }

                        Section
                        {
                            PackageAndTapOverviewBox()
                        }

                        Section
                        {
                            AnalyticsStatusBox()
                        }

                        if appState.cachedDownloadsFolderSize != 0
                        {
                            Section
                            {
                                CachedDownloadsFolderInfoBox()
                            }
                        }
                    }
                    .scrollDisabled(!isOutdatedPackageDropdownExpanded)

                    ButtonBottomRow 
                    {
                        HStack
                        {
                            Spacer()

                            Button
                            {
                                AppConstants.logger.info("Would perform maintenance")
                                appState.isShowingMaintenanceSheet.toggle()
                            } label: {
                                Text("start-page.open-maintenance")
                            }
                        }
                    }
                }
                .sheet(isPresented: $isShowingTemporaryLicensingSheet, content: {
                    temporaryLicensingSheet
                })
            }
        }
        .task(priority: .background)
        {
            if outdatedPackageTracker.allOutdatedPackages.isEmpty
            {
                appState.isCheckingForPackageUpdates = true

                await shell(AppConstants.brewExecutablePath, ["update"])

                do
                {
                    outdatedPackageTracker.allOutdatedPackages = try await getListOfUpgradeablePackages(brewData: brewData)
                }
                catch let outdatedPackageRetrievalError as OutdatedPackageRetrievalError
                {
                    switch outdatedPackageRetrievalError
                    {
                    case .homeNotSet:
                        appState.fatalAlertType = .homePathNotSet
                        appState.isShowingFatalError = true
                    case .otherError:
                            AppConstants.logger.error("Something went wrong")
                    }
                }
                catch
                {
                    AppConstants.logger.error("Unspecified error while pulling package updates")
                }

                withAnimation
                {
                    appState.isCheckingForPackageUpdates = false
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $dragOver) { providers -> Bool in
            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                if let data = data, let path = String(data: data, encoding: .utf8), let url = URL(string: path as String) {
                    
                    if url.pathExtension == "brewbak" || url.pathExtension.isEmpty {
                        AppConstants.logger.debug("Correct File Format")
                        
                        Task(priority: .userInitiated) 
                        {
                            try await importBrewfile(from: url, appState: appState, brewData: brewData)
                        }
                        
                    } else {
                        AppConstants.logger.error("Incorrect file format")
                    }
                }
            })
            return true
        }
    }
    
    var temporaryLicensingSheet: some View
    {
        VStack(alignment: .center, spacing: 15)
        {
            Text("temporary-licensing.sheet.title")
                .font(.title)
            
            Text("temporary-licensing.sheet.body")
            
            VStack(alignment: .leading, spacing: 5)
            {
                Text("temporary-licensing.sheet.email-title")
                
                TextField(text: $emailToCheck, prompt: Text("temporary-licensing.email-field.prompt")) {
                    
                }
            }
            
            if isCheckingEmail
            {
                ProgressView()
            }
            else
            {
                if let isEmailValid
                {
                    if isEmailValid
                    {
                        VStack(spacing: 10)
                        {
                            Label("temporary-licensing.email-\(emailToCheck)-valid", systemImage: "checkmark.circle")
                                .foregroundColor(.green)
                            
                            Text("temporary-licensing.sheet.email-valid-instructions")
                        }
                    }
                    else
                    {
                        VStack(spacing: 10)
                        {
                            Label("temporary-licensing.email-\(emailToCheck)-invalid", systemImage: "xmark.circle")
                                .foregroundColor(.red)
                            
                            Text("temporary-licensing.sheet.email-invalid-instructions")
                        }
                    }
                }
            }
            
            HStack(alignment: .center, spacing: 5)
            {
                Button
                {
                    isShowingTemporaryLicensingSheet.toggle()
                } label: {
                    Text("action.close")
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button
                {
                    Task(priority: .userInitiated)
                    {
                        isCheckingEmail = true
                        
                        defer
                        {
                            isCheckingEmail = false
                        }
                        
                        isEmailValid = try await checkIfUserBoughtCork(for: emailToCheck)
                    }
                } label: {
                    Text("action.check-email")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .fixedSize()
        .onChange(of: emailToCheck)
        { _ in
            isEmailValid = nil
        }
    }
}
