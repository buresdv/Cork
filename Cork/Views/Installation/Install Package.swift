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

    @State var installationSteps: InstallationSteps = .ready

    @State var packageInstallTrackingNumber: Float = 0

    @State private var willHaveToFetchPackageDependencies: Bool = false

    @FocusState var isSearchFieldFocused: Bool

    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch installationSteps
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
                                installationSteps = .searching
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

                            installationSteps = .presentingSearchResults
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
                                installationSteps = .searching
                            } label: {
                                Text("Search")
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                        else
                        {
                            Button
                            {
                                installationSteps = .installing
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
                    ProgressView(value: packageInstallTrackingNumber)
                    {
                        if willHaveToFetchPackageDependencies
                        {
                            HStack(spacing: 15)
                            {
                                Text("Fetching dependencies...")
                                ProgressView()
                                    .scaleEffect(0.5, anchor: .center)
                                    .frame(width: 1, height: 1)
                            }
                        }
                        else
                        {
                            if installationProgressTracker.packagesStillLeftToInstall.count != 0
                            {
                                Text("Installing \(installationProgressTracker.packagesStillLeftToInstall.count) \(installationProgressTracker.packagesStillLeftToInstall.count >= 2 ? "packages" : "package")")
                                    .onAppear
                                    {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1 ... 3))
                                        { // If nothing happened after three seconds, the package install either got stuck or it's fetching dependencies. Let's be generous and say it's fetching dependencies. Make it seems like it's actually working
                                            // Seriously, fuck the interface. It could throw me a bone, but no
                                            if willHaveToFetchPackageDependencies == false
                                            {
                                                willHaveToFetchPackageDependencies = true
                                                packageInstallTrackingNumber = packageInstallTrackingNumber + Float.random(in: 0 ... 0.2)
                                            }
                                        }
                                    }
                            }
                            else
                            {
                                Text("Validating installations...") // This doesn't actually do anything, but it's better to make the user think something is happening instead of showing "Installing 0 packages"
                            }
                        }
                    }

                    if installationProgressTracker.packagesStillLeftToInstall.count != 0
                    {
                        if showPackagesStillLeftToInstall
                        {
                            Text("Packages currently being installed")
                                .font(.headline)
                            List(installationProgressTracker.packagesStillLeftToInstall, id: \.self)
                            { packageName in
                                Text(packageName)
                            }
                            .listStyle(.bordered(alternatesRowBackgrounds: true))
                            .frame(height: 70)
                        }
                    }
                }
                .onAppear
                {
                    for requestedPackage in foundPackageSelection
                    {
                        // print(getPackageFromUUID(requestedPackageUUID: requestedPackage, tracker: searchResultTracker))

                        let packageToInstall: BrewPackage = getPackageFromUUID(requestedPackageUUID: requestedPackage, tracker: searchResultTracker)

                        installationProgressTracker.packagesStillLeftToInstall.append(packageToInstall.name)

                        print("Packages to install: \(installationProgressTracker.packagesStillLeftToInstall)")

                        installationProgressTracker.packageBeingCurrentlyInstalled = packageToInstall.name

                        Task(priority: .userInitiated)
                        {
                            do
                            {
                                // We have to do a little trolling to make the user feel like the program isn't frozen
                                // After a random time up to 2s, move the progress line a little bit. I don't want them to think the program got stuck.
                                // Slow-ass brew just doesn't install the packages fast enough
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1 ... 3))
                                {
                                    packageInstallTrackingNumber = packageInstallTrackingNumber + Float.random(in: 0 ... 0.1)
                                }

                                let installationResult = try await installPackage(package: packageToInstall, installationProgressTracker: installationProgressTracker, brewData: brewData) // I had to remove the async-let declaration here because it was causing problems with the if condition below (I couldn't compare it to two strings). If it causes problems, revert it and use this solution instead: https://elk.zone/mstdn.social/@ctietze@mastodon.social/109896906687849242

                                print("Installation result: \(installationResult)")

                                
                                if installationResult.standardOutput.contains("Pouring") || installationResult.standardOutput.contains("was successfully installed!")
                                {
                                    
                                    if installationProgressTracker.packagesStillLeftToInstall.count == 0
                                    {
                                        packageInstallTrackingNumber = 1

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) // Pause for a second when the package is installed so the user realizes it
                                        {
                                            willHaveToFetchPackageDependencies = false
                                            installationSteps = .finished
                                        }
                                    }
                                    else
                                    {
                                        packageInstallTrackingNumber = Float(1 / installationProgressTracker.packagesStillLeftToInstall.count)
                                    }
                                }
                                else if installationResult.standardOutput.contains("Fetching dependencies")
                                {
                                    print("Will have to fetch some dependencies for \(packageToInstall)")
                                    willHaveToFetchPackageDependencies = true
                                }
                            }
                            catch let error as NSError
                            {
                                print("Error while installing package \(packageToInstall.name): \(error)")
                            }
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
