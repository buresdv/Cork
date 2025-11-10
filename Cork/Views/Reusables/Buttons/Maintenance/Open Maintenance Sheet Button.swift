//
//  Open Maintenance Sheet Button.swift
//  Cork
//
//  Created by David Bureš - Virtual on 12.06.2025.
//

import SwiftUI
import CorkModels

struct OpenMaintenanceSheetButton: View
{
    let appState: AppState
    
    enum LabelType: LocalizedStringKey
    {
        case openMaintenanceSheet = "start-page.open-maintenance"
        case performMaintenance = "navigation.menu.maintenance.perform"
    }
    
    let labelType: LabelType
    
    var body: some View
    {
        Button
        {
            appState.showSheet(ofType: .maintenance(fastCacheDeletion: false))
        } label: {
            Label(labelType.rawValue, systemImage: "arrow.3.trianglepath")
        }
        .help("navigation.maintenance.help")
    }
}
