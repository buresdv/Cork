//
//  Installation Pane.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct InstallationAndUninstallationPane: View
{
    @AppStorage("showCompatibilityWarning") var showCompatibilityWarning: Bool = true

    @AppStorage("showPackagesStillLeftToInstall") var showPackagesStillLeftToInstall: Bool = false

    @AppStorage("purgeCacheAfterEveryUninstallation") var purgeCacheAfterEveryUninstallation: Bool = false
    @AppStorage("removeOrphansAfterEveryUninstallation") var removeOrphansAfterEveryUninstallation: Bool = false

    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false

    @State private var isShowingDeepUninstallConfirmation: Bool = false
    
    var body: some View
    {
        SettingsPaneTemplate
        {
            Form
            {
                /*
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
                 */

                LabeledContent {
                    Toggle(isOn: $showCompatibilityWarning)
                    {
                        Text("Check package compatibility")
                    }
                } label: {
                    Text("Compatibility:")
                }

                LabeledContent
                {
                    VStack(alignment: .leading)
                    {
                        Toggle(isOn: $allowMoreCompleteUninstallations)
                        {
                            Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation")
                        }
                        .onChange(of: allowMoreCompleteUninstallations, perform: { newValue in
                            if newValue == true
                            {
                                isShowingDeepUninstallConfirmation = true
                            }
                        })
                        .alert(isPresented: $isShowingDeepUninstallConfirmation) {
                            Alert(
                                title: Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.title"),
                                message: Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.body"),
                                primaryButton: .default(Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.alert.confirm"), action: {
                                    allowMoreCompleteUninstallations = true
                                    isShowingDeepUninstallConfirmation = false
                                }),
                                secondaryButton: .cancel({
                                    allowMoreCompleteUninstallations = false
                                    isShowingDeepUninstallConfirmation = false
                                }))
                        }

                        HStack(alignment: .top)
                        {
                            Text("􀇾")
                            Text("settings.install-uninstall.uninstallation.allow-more-complete-uninstallation.warning")
                        }
                        .font(.caption)
                        .foregroundColor(Color(nsColor: NSColor.systemGray))
                    }
                } label: {
                    Text("settings.dangerous")
                }
            }
        }
    }
}
