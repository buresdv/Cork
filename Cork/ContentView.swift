//
//  ContentView.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var brewData = BrewDataStorage()
    
    @State private var multiSelection = Set<UUID>()
    
    @State private var isShowingInstallSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    
    var body: some View {
        VStack {
            List(selection: $multiSelection) {
                Section("Installed Formulae") {
                    Text("Installed Formulae")
                        .font(.headline)
                    if brewData.installedFormulae.count != 0 {
                        ForEach(brewData.installedFormulae) { package in
                            
                            PackageListItem(packageItem: package)
                        }
                    } else {
                        ProgressView()
                    }
                }
                
                Section("Installed Casks") {
                    Text("Installed Casks")
                        .font(.headline)
                    if brewData.installedCasks.count != 0 {
                        ForEach(brewData.installedCasks) { package in
                            PackageListItem(packageItem: package)
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
            .listStyle(.bordered)
            .toolbar {
                VStack(alignment: .leading) {
                    Text("Cork")
                        .font(.headline)
                    Text("\(brewData.installedCasks.count + brewData.installedFormulae.count) packages installed")
                        .font(.subheadline)
                }
                
                Spacer()
                
                if !multiSelection.isEmpty { // If the user selected a package, show a button to uninstall it
                        Button {
                            print("Clicked Delete")
                            isShowingAlert.toggle()
                        } label: {
                            Label {
                                Text("Remove Package")
                            } icon: {
                                Image(systemName: "trash")
                            }
                        }
                        .alert("Are you sure you want to delete the selected package(s)?", isPresented: $isShowingAlert) {
                            Button("Delete", role: .destructive) {
                                
                            }
                            Button("Cancel", role: .cancel) {
                                isShowingAlert.toggle()
                            }
                        } message: {
                            Text("Deleting a package will completely remove it from your Mac. You will have to reinstall the package if you want to use it again.")
                            Text("This action cannot be undone.")
                        }

                }
                
                Button {
                    isShowingInstallSheet.toggle()
                } label: {
                    Label {
                        Text("Add Package")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }

            }
        }
        .padding()
        .environmentObject(brewData)
        .onAppear {
            
            Task {
                print("Started Command task at \(Date())")
                do {
                    let commandResult = try await executeCommand("/opt/homebrew/bin list")
                    print(commandResult)
                } catch let error as NSError {
                    print("Error executing command: \(error)")
                }
            }
            
            Task { // Task that gets the contents of the Cellar folder
                print("Started Cellar task at \(Date())")
                let contentsOfCellarFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCellarPath)
                
                for package in contentsOfCellarFolder {
                    brewData.installedFormulae.append(BrewPackage(name: package))
                    print("Appended \(package)")
                }
                
                //print(brewData.installedFormulae!)
            }
            
            Task { // Task that gets the contents of the Cask folder
                print("Started Cask task at \(Date())")
                let contentsOfCaskFolder = await getContentsOfFolder(targetFolder: AppConstantsLocal.brewCaskPath)
                
                for package in contentsOfCaskFolder {
                    brewData.installedCasks.append(BrewPackage(name: package))
                    print("Appended \(package)")
                }
                
                //print(brewData.installedCasks!)
            }
        }
        .sheet(isPresented: $isShowingInstallSheet) {
            AddPackageView(isShowingSheet: $isShowingInstallSheet)
        }
    }
}
