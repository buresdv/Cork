//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct AddFormulaView: View
{
    @Binding var isShowingSheet: Bool

    @State private var packageRequested: String = ""

    @EnvironmentObject var brewData: BrewDataStorage

    @State private var foundPackageSelection = Set<UUID>()

    @ObservedObject var searchResultTracker = SearchResultTracker()
    @ObservedObject var installationProgressTracker = InstallationProgressTracker()

    @State var packageInstallationProcessStep: PackageInstallationProcessSteps = .ready

    @State var packageInstallTrackingNumber: Float = 0

    @FocusState var isSearchFieldFocused: Bool

    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch packageInstallationProcessStep
            {
            case .ready:
                SheetWithTitle(title: "Install packages")
                {
                    VStack
                    {
                        TextField("Search for packages...", text: $packageRequested)
                        { _ in
                            foundPackageSelection = Set<UUID>() // Clear all selected items when the user looks for a different package
                        }

                        HStack
                        {
                            DismissSheetButton(isShowingSheet: $isShowingSheet)

                            Spacer()

                            Button
                            {
                                packageInstallationProcessStep = .searching
                            } label: {
                                Text("Search")
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                }

            case .searching:
                ProgressView("Searching for \(packageRequested)...")
                    .onAppear
                    {
                        Task
                        {
                            searchResultTracker.foundFormulae = []
                            searchResultTracker.foundCasks = []

                            async let foundFormulae = try searchForPackage(packageName: packageRequested, packageType: .formula)
                            async let foundCasks = try searchForPackage(packageName: packageRequested, packageType: .cask)

                            for formula in try await foundFormulae
                            {
                                searchResultTracker.foundFormulae.append(BrewPackage(name: formula, isCask: false, installedOn: nil, versions: [], sizeInBytes: nil))
                            }
                            for cask in try await foundCasks
                            {
                                searchResultTracker.foundCasks.append(BrewPackage(name: cask, isCask: true, installedOn: nil, versions: [], sizeInBytes: nil))
                            }

                            packageInstallationProcessStep = .presentingSearchResults
                        }
                    }

            case .presentingSearchResults:
                VStack
                {
                    TextField("Search for packages...", text: $packageRequested)
                    { _ in
                        foundPackageSelection = Set<UUID>() // Clear all selected items when the user looks for a different package
                    }
                    .focused($isSearchFieldFocused)

                    List(selection: $foundPackageSelection)
                    {
                        Section("Found Formulae")
                        {
                            ForEach(searchResultTracker.foundFormulae)
                            { formula in
                                SearchResultRow(packageName: formula.name, isCask: formula.isCask)
                            }
                        }
                        Section("Found Casks")
                        {
                            ForEach(searchResultTracker.foundCasks)
                            { cask in
                                SearchResultRow(packageName: cask.name, isCask: cask.isCask)
                            }
                        }
                    }
                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                    .frame(width: 300, height: 300)

                    HStack
                    {
                        DismissSheetButton(isShowingSheet: $isShowingSheet)

                        Spacer()

                        if isSearchFieldFocused
                        {
                            Button
                            {
                                packageInstallationProcessStep = .searching
                            } label: {
                                Text("Search")
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                        else
                        {
                            Button
                            {
                                for requestedPackage in foundPackageSelection
                                {
                                    print(getPackageFromUUID(requestedPackageUUID: requestedPackage, tracker: searchResultTracker))

                                    let packageToInstall: BrewPackage = getPackageFromUUID(requestedPackageUUID: requestedPackage, tracker: searchResultTracker)

                                    installationProgressTracker.packagesBeingInstalled.append(PackageInProgressOfBeingInstalled(package: packageToInstall, installationStage: .ready, packageInstallationProgress: 0))
                                    
                                    print("Packages to install: \(installationProgressTracker.packagesBeingInstalled)")
                                    
                                    installationProgressTracker.packageBeingCurrentlyInstalled = packageToInstall.name
                                    
                                }
                                
                                print(installationProgressTracker.packagesBeingInstalled)
                                
                                packageInstallationProcessStep = .installing
                            } label: {
                                Text("Install")
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                }

            case .installing:
                VStack(alignment: .leading)
                {
                    
                    ForEach(installationProgressTracker.packagesBeingInstalled)
                    { packageBeingInstalled in
                        
                        if packageBeingInstalled.installationStage != .finished
                        {
                            ProgressView(value: installationProgressTracker.packagesBeingInstalled[0].packageInstallationProgress, total: 10)
                            {
                                switch packageBeingInstalled.installationStage
                                {
                                    case .ready:
                                        Text("Firing up...")
                                        
                                    case .loadingDependencies:
                                        Text("Loading Dependencies...")
                                        
                                    case .fetchingDependencies:
                                        Text("Fetching Dependency \(installationProgressTracker.numberInLineOfPackageCurrentlyBeingFetched)...")
                                        
                                    case .installingDependencies:
                                        Text("Installing Dependency \(installationProgressTracker.numberInLineOfPackageCurrentlyBeingInstalled)/\(installationProgressTracker.numberOfPackageDependencies)...")
                                        
                                    case .installingPackage:
                                        Text("Installing Package...")
                                        
                                    case .finished:
                                        Text("Done!")
                                }
                            }
                        }
                        else
                        { // Show this when the installation is finished
                            Text("Done")
                                .onAppear
                            {
                                packageInstallationProcessStep = .finished
                            }
                        }
                    }
                    
                }
                .onAppear
                {
                    for var packageToInstall in installationProgressTracker.packagesBeingInstalled
                    {
                        Task(priority: .userInitiated)
                        {
                            let installationResult = try! await installPackage(installationProgressTracker: installationProgressTracker, brewData: brewData)
                            print("Installation result: \(installationResult)")
                        }
                    }
                }

            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal") {
                        HeadlineWithSubheadline(headline: "Packages successfuly installed", subheadline: "There were no errors", alignment: .leading)
                    }
                }
            }
        }
        .padding()
    }
}
