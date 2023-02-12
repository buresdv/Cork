//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

class SearchResultTracker: ObservableObject
{
    @Published var foundFormulae: [SearchResult] = .init()
    @Published var foundCasks: [SearchResult] = .init()
    @Published var selectedPackagesForInstallation: [String] = .init()
}

class InstallationProgressTracker: ObservableObject
{
    @Published var progressNumber: Float = 0
    @Published var packageBeingCurrentlyInstalled: String = ""

    @Published var isShowingInstallationFailureAlert: Bool = false
}

enum InstallationSteps
{
    case ready, searching, presentingSearchResults, installing, finished
}

struct AddFormulaView: View
{
    @Binding var isShowingSheet: Bool

    @State private var packageRequested: String = ""
    @State private var isShowingListLoader: Bool = false
    @State private var isShowingResultsList: Bool = false

    @State var brewData: BrewDataStorage

    @State private var foundPackageSelection = Set<UUID>()

    @ObservedObject var searchResultTracker = SearchResultTracker()
    @ObservedObject var installationProgressTracker = InstallationProgressTracker()

    @State var installationSteps: InstallationSteps = .ready

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

            case .presentingSearchResults:
                VStack
                {
                    TextField("Search for packages...", text: $packageRequested)
                    { _ in
                        foundPackageSelection = Set<UUID>() // Clear all selected items when the user looks for a different package
                    }

                    List(selection: $foundPackageSelection)
                    {
                        Section("Found Formulae")
                        {
                            ForEach(searchResultTracker.foundFormulae)
                            { formula in
                                SearchResultRow(packageName: formula.packageName, isCask: formula.isCask)
                            }
                        }
                        Section("Found Casks")
                        {
                            ForEach(searchResultTracker.foundCasks)
                            { cask in
                                SearchResultRow(packageName: cask.packageName, isCask: cask.isCask)
                            }
                        }
                    }

                    HStack
                    {
                        DismissSheetButton(isShowingSheet: $isShowingSheet)

                        Spacer()

                        Button
                        {
                            installationSteps = .installing
                        } label: {
                            Text("Install")
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }

            case .installing:
                ProgressView(value: installationProgressTracker.progressNumber)
                {
                    Text("Installing \(installationProgressTracker.packageBeingCurrentlyInstalled)")
                }
                .onAppear
                {}

            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    HeadlineWithSubheadline(headline: "Packages successfuly installed", subheadline: "There were no errors", alignment: .center)
                }
            }
        }
        .padding()

        /* VStack(alignment: .leading)
         {
             Text("Install Packages")
                 .font(.headline)
                 .padding(.leading)
             TextField("Search For Packages...", text: $packageRequested, onEditingChanged: { _ in
                 foundPackageSelection = Set<UUID>() // Clear all selected items when the user looks for a different package
             })
             .padding(.horizontal)

             if isShowingListLoader
             {
                 ProgressView()
             }
             else if installationProgressTracker.progressNumber != 0
             {
                 InstallProgressTrackerView(progress: $installationProgressTracker.progressNumber, currentlyInstallingPackage: $installationProgressTracker.packageBeingCurrentlyInstalled)
             }
             else if isShowingResultsList
             {
                 List(selection: $foundPackageSelection)
                 {
                     if !searchResultTracker.foundFormulae.isEmpty
                     {
                         Section("Found Formulae")
                         {
                             ForEach(searchResultTracker.foundFormulae)
                             { formula in
                                 HStack
                                 {
                                     Text(formula.packageName)
                                     if brewData.installedFormulae.contains(where: { $0.name == formula.packageName })
                                     {
                                         PillText(text: "Already Installed")
                                     }
                                 }
                             }
                         }
                     }

                     if !searchResultTracker.foundCasks.isEmpty
                     {
                         Section("Found Casks")
                         {
                             ForEach(searchResultTracker.foundCasks)
                             { cask in

                                 HStack
                                 {
                                     Text(cask.packageName)
                                     if brewData.installedCasks.contains(where: { $0.name == cask.packageName })
                                     {
                                         PillText(text: "Already Installed")
                                     }
                                 }

                             }
                         }
                     }
                 }
                 .listStyle(.inset(alternatesRowBackgrounds: true))
                 .frame(width: 300, height: 300)
             }

             HStack
             {
                 Button
                 {
                     isShowingSheet.toggle()
                 } label: {
                     Text("Cancel")
                 }
                 .keyboardShortcut(.cancelAction)

                 Spacer()

                 if foundPackageSelection.isEmpty
                 {
                     Button
                     {
                         isShowingResultsList = false
                         searchResultTracker.foundFormulae = [SearchResult]()
                         searchResultTracker.foundCasks = [SearchResult]()

                         Task
                         {
                             isShowingListLoader = true
                             print("Loader status: \(isShowingListLoader)")

                             do
                             {
                                 let foundFormulae: [String] = try await searchForPackage(packageName: packageRequested, packageType: .formula)
                                 let foundCasks: [String] = try await searchForPackage(packageName: packageRequested, packageType: .cask)

                                 for formula in foundFormulae
                                 {
                                     searchResultTracker.foundFormulae.append(SearchResult(packageName: formula, isCask: false))
                                 }

                                 for cask in foundCasks
                                 {
                                     searchResultTracker.foundCasks.append(SearchResult(packageName: cask, isCask: true))
                                 }
                             }
                             catch let packageRetrievalError as NSError
                             {
                                 print(packageRetrievalError)
                             }

                             isShowingListLoader = false
                             isShowingResultsList = true
                         }
                     } label: {
                         Text("Search")
                     }
                     .keyboardShortcut(.defaultAction)
                 }
                 else
                 {
                     HStack
                     {
                         Button
                         {
                             // TODO: Add logic that will show the user more information about the selected package

                             let selectedPackages: [String] = getPackageNamesFromUUID(selectionBinding: foundPackageSelection, tracker: searchResultTracker)

                             for selectedPackage in selectedPackages
                             {
                                 PackageDetailWindow(package: selectedPackage, tracker: searchResultTracker, brewData: brewData).openNewWindow(with: "Detail - \(selectedPackage)")
                             }

                         } label: {
                             Text("More info")
                         }
                         .keyboardShortcut(.tab)

                         Button
                         {
                             // TODO: Optimize this
                             searchResultTracker.selectedPackagesForInstallation = [String]()

                             installSelectedPackages(packageArray: getPackageNamesFromUUID(selectionBinding: foundPackageSelection, tracker: searchResultTracker), tracker: installationProgressTracker, brewData: brewData)

                             print(searchResultTracker.selectedPackagesForInstallation)
                         } label: {
                             Text("Install")
                         }
                         .keyboardShortcut(.defaultAction)
                     }
                 }
             }
             .padding([.horizontal, .top])
         }
         .padding(.vertical)
         .frame(width: 300)
         .alert("Error installing package", isPresented: $installationProgressTracker.isShowingInstallationFailureAlert)
         {
             Button("Close", role: .cancel)
             {
                 installationProgressTracker.isShowingInstallationFailureAlert = false
             }
         } message: {
             Text("An error occured while installing one of the selected packages.")
             Text("Please try again in a few minutes")
         } */
    }
}
