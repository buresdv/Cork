//
//  Installation Pane.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct InstallationAndUninstallationPane: View
{
    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false

    @AppStorage("purgeCacheAfterEveryUninstallation") var purgeCacheAfterEveryUninstallation: Bool = false
    @AppStorage("removeOrphansAfterEveryUninstallation") var removeOrphansAfterEveryUninstallation: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                LabeledContent
                {
                    Toggle(isOn: $showPackagesStillLeftToInstall)
                    {
                        Text("Show list of packages currently being installed")
                    }
                } label: {
                    Text("Installation:")
                }

                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $purgeCacheAfterEveryUninstallation)
                        {
                            Text("Purge cache after uninstalling packages")
                        }
                        Toggle(isOn: $removeOrphansAfterEveryUninstallation)
                        {
                            Text("Remove orphans after uninstalling packages")
                        }
                    }
                } label: {
                    Text("Uninstallation:")
                }
            }
        }
    }
}
