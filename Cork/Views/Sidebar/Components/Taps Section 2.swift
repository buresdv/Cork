//
//  Taps Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

struct TapsSection: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var availableTaps: AvailableTaps
    
    @EnvironmentObject var selectedTapInfo: SelectedTapInfo
    
    @Binding var searchText: String
    
    var body: some View {
        Section("sidebar.section.added-taps")
        {
            if availableTaps.addedTaps.count != 0
            {
                ForEach(searchText.isEmpty || searchText.contains("#") ? availableTaps.addedTaps : availableTaps.addedTaps.filter { $0.name.contains(searchText) })
                { tap in
                    
                    NavigationLink(tag: tap.id, selection: $appState.navigationSelection)
                    {
                        TapDetailView(tap: tap, selectedTapInfo: selectedTapInfo)
                    } label: {
                        Text(tap.name)
                    }
                    .contextMenu
                    {
                        Button
                        {
                            Task(priority: .userInitiated)
                            {
                                print("Would remove \(tap.name)")
                                try await removeTap(name: tap.name, availableTaps: availableTaps, appState: appState)
                            }
                        } label: {
                            Text("sidebar.section.added-taps.contextmenu.remove-\(tap.name)")
                        }
                        .alert(isPresented: $appState.isShowingRemoveTapFailedAlert, content: {
                            Alert(title: Text("sidebar.section.added-taps.remove.title-\(tap.name)"), message: Text("sidebar.section.added-taps.remove.message"), dismissButton: .default(Text("action.close"), action: {
                                appState.isShowingRemoveTapFailedAlert = false
                            }))
                        })
                    }
                }
            }
            else
            {
                ProgressView()
            }
        }
    }
}
