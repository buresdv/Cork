//
//  Installation Pane.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct InstallationAndUninstallationPane: View {
    
    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false
    
    var body: some View {
        SettingsPaneTemplate {
            Form {
                Toggle(isOn: $showPackagesStillLeftToInstall) {
                    Text("Show list of packages currently being installed")
                }
            }
        }
    }
}
