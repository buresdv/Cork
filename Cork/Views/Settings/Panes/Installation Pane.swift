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
                        Text("settings.install-uninstall.installation.toggle")
                    }
                } label: {
                    Text("settings.install-uninstall.installation")
                }

                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $purgeCacheAfterEveryUninstallation)
                        {
                            Text("settings.install-uninstall.uninstallation.purge-cache")
                        }
                        Toggle(isOn: $removeOrphansAfterEveryUninstallation)
                        {
                            Text("settings.install-uninstall.uninstallation.remove-orphans")
                        }
                    }
                } label: {
                    Text("settings.install-uninstall.uninstallation")
                }
            }
        }
    }
}
