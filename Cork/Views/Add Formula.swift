//
//  Add Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI


class SearchResultTracker: ObservableObject {
    @Published var foundFormulae: [String] = [String]()
    @Published var foundCasks: [String] = [String]()
}

struct AddFormulaView: View {
    @Binding var isShowingSheet: Bool
    
    @State private var packageRequested: String = ""
    @State private var isShowingListLoader: Bool = false
    
    @ObservedObject var searchResultTracker = SearchResultTracker()
    
    var body: some View {
        VStack {
            TextField("Search For Formula...", text: $packageRequested)
                .padding(.horizontal)
            
            if isShowingListLoader == false {
                List {
                    Section("Found Formulae") {
                        ForEach(searchResultTracker.foundFormulae) { formula in
                            Text(formula)
                        }
                    }
                    
                    Section("Found Casks") {
                        Text("AAaa")
                        Text("AAaa")
                        Text("AAaa")
                        Text("AAaa")
                        Text("AAaa")
                        Text("AAaa")
                        Text("AAaa")
                        Text("AAaa")
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            } else {
                ProgressView()
            }
            
            HStack {
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Text("Cancel")
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button {
                    Task {
                        isShowingListLoader = true
                        print("Loader status: \(isShowingListLoader)")
                        let searchResults = await shell("/opt/homebrew/bin/brew", ["search", packageRequested])!
                        
                        print(searchResults)
                        
                        let resultArray: [String] = searchResults.components(separatedBy: "\n")
                        
                        print(resultArray)
                        
                        
                        if resultArray.contains("==> Formulae") && resultArray.contains("==> Casks") {
                            
                            searchResultTracker.foundFormulae = Array(resultArray[resultArray.firstIndex(of: "==> Formulae")!..<resultArray.firstIndex(of: "==> Casks")!])
                            searchResultTracker.foundCasks = Array(resultArray[resultArray.firstIndex(of: "==> Casks")!..<resultArray.count])
                            
                            print(searchResultTracker.foundFormulae)
                            print(searchResultTracker.foundCasks)
                        }
                        
                        isShowingListLoader = false
                    }
                } label: {
                    Text("Search")
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .frame(minWidth: 300, minHeight: 300)
    }
}
