//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI


class SearchResultTracker: ObservableObject {
    @Published var foundFormulae: [SearchResult] = [SearchResult]()
    @Published var foundCasks: [SearchResult] = [SearchResult]()
    @Published var selectedPackagesForInstallation: [String] = [String]()
}

class InstallationProgressTracker: ObservableObject {
    @Published var progressNumber: Float = 0
    @Published var packageBeingCurrentlyInstalled: String = ""
    
    @Published var isShowingInstallationFailureAlert: Bool = false
}

struct AddFormulaView: View {
    @Binding var isShowingSheet: Bool
    
    @State private var packageRequested: String = ""
    @State private var isShowingListLoader: Bool = false
    @State private var isShowingResultsList: Bool = false
    
    @State var brewData: BrewDataStorage
    
    @State private var foundPackageSelection = Set<UUID>()
    
    @ObservedObject var searchResultTracker = SearchResultTracker()
    @ObservedObject var installationProgressTracker = InstallationProgressTracker()
    
    var body: some View {
        VStack {
            TextField("Search For Formula...", text: $packageRequested)
                .padding(.horizontal)
            
            if isShowingListLoader {
                ProgressView()
            } else if installationProgressTracker.progressNumber != 0 {
                InstallProgressTrackerView(progress: $installationProgressTracker.progressNumber, currentlyInstallingPackage: $installationProgressTracker.packageBeingCurrentlyInstalled)
            } else if isShowingResultsList {
                List(selection: $foundPackageSelection) {
                    if !searchResultTracker.foundFormulae.isEmpty {
                        Section("Found Formulae") {
                            ForEach(searchResultTracker.foundFormulae) { formula in
                                Text(formula.packageName)
                            }
                        }
                    }
                    
                    if !searchResultTracker.foundCasks.isEmpty {
                        Section("Found Casks") {
                            ForEach(searchResultTracker.foundCasks) { cask in
                                Text(cask.packageName)
                            }
                        }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .frame(width: 300, height: 300)
            }
            
            HStack {
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Text("Cancel")
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                if foundPackageSelection.isEmpty {
                    Button {
                        isShowingResultsList = false
                        searchResultTracker.foundFormulae = [SearchResult]()
                        searchResultTracker.foundCasks = [SearchResult]()
                        
                        Task {
                            isShowingListLoader = true
                            print("Loader status: \(isShowingListLoader)")
                            let searchResults = await shell("/opt/homebrew/bin/brew", ["search", packageRequested])!
                            
                            print(searchResults)
                            
                            let resultArray: [String] = searchResults.components(separatedBy: "\n")
                            
                            print(resultArray)
                            
                            var foundFormulaeRaw = [String]()
                            var foundCasksRaw = [String]()
                            
                            if resultArray.contains("==> Formulae") && resultArray.contains("==> Casks") {
                                
                                foundFormulaeRaw = Array(resultArray[resultArray.firstIndex(of: "==> Formulae")!..<resultArray.firstIndex(of: "==> Casks")!])
                                foundFormulaeRaw.removeFirst()
                                foundFormulaeRaw.removeLast()
                                
                                foundCasksRaw = Array(resultArray[resultArray.firstIndex(of: "==> Casks")!..<resultArray.count])
                                foundCasksRaw.removeFirst()
                                foundCasksRaw.removeLast()
                                
                                for formula in foundFormulaeRaw {
                                    searchResultTracker.foundFormulae.append(SearchResult(packageName: formula))
                                }
                                
                                for cask in foundCasksRaw {
                                    searchResultTracker.foundCasks.append(SearchResult(packageName: cask))
                                }
                                
                                print(searchResultTracker.foundFormulae)
                                print(searchResultTracker.foundCasks)
                            } else if resultArray.contains("==> Formulae") {
                                foundFormulaeRaw = Array(resultArray[resultArray.firstIndex(of: "==> Formulae")!..<resultArray.count])
                                foundFormulaeRaw.removeFirst()
                                foundFormulaeRaw.removeLast()
                                
                                for formula in foundFormulaeRaw {
                                    searchResultTracker.foundFormulae.append(SearchResult(packageName: formula))
                                }
                                
                                print(searchResultTracker.foundFormulae)
                                
                            } else if resultArray.contains("==> Casks") {
                                foundCasksRaw = Array(resultArray[resultArray.firstIndex(of: "==> Casks")!..<resultArray.count])
                                foundCasksRaw.removeFirst()
                                foundCasksRaw.removeLast()
                                
                                for cask in foundCasksRaw {
                                    searchResultTracker.foundCasks.append(SearchResult(packageName: cask))
                                }
                                
                                print(searchResultTracker.foundCasks)
                            } else {
                                
                            }
                            
                            isShowingListLoader = false
                            isShowingResultsList = true
                        }
                    } label: {
                        Text("Search")
                    }
                    .keyboardShortcut(.defaultAction)
                } else {
                    HStack {
                        Button {
                            // TODO: Add logic that will show the user more information about the selected package
                            
                            let selectedPackages: [String] = getPackageNamesFromUUID(selectionBinding: foundPackageSelection, tracker: searchResultTracker)
                            
                            for selectedPackage in selectedPackages {
                                PackageDetailWindow(package: selectedPackage).openNewWindow()
                            }
                            
                        } label: {
                            Text("More info")
                        }
                        .keyboardShortcut(.tab)
                        
                        Button {
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
            .padding(.horizontal)
        }
        .padding(.vertical)
        .frame(width: 300)
        .alert("Error installing package", isPresented: $installationProgressTracker.isShowingInstallationFailureAlert) {
            Button("Close", role: .cancel) {
                installationProgressTracker.isShowingInstallationFailureAlert = false
            }
        } message: {
            Text("An error occured while installing one of the selected packages.")
            Text("Please try again in a feww minutes")
        }
    }
}
