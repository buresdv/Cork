//
//  Cask Executable Warnings.swift
//  CorkFeature_XattrHandling
//
//  Created by David Bureš - P on 12.10.2026.
//

import SwiftUI
import ApplicationInspector
import CorkFeature_XattrHandling
import FactoryKit
import CorkModels

struct CaskExecutableWarnings: View
{
    @Environment(\.caskApplication) var caskApplication
    
    @InjectedObservable(\.appState) var appState
    
    @State private var isShowingQuarantineRemovalConfirmationDialog: Bool = false
    
    var body: some View
    {
        if let caskApplication
        {
            if caskApplication.isQuarantined
            {
                Section
                {
                    HStack(alignment: .center, spacing: 10)
                    {
                        Image(systemName: "waveform.path.ecg.text.clipboard")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15)
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading)
                        {
                            Text("package-details.cask.warning.is-quarantined")
                            Text("package-details.cask.warning.is-quarantined.explanation")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Menu("action.open-\(caskApplication.name)")
                        {
                            Button
                            {
                                isShowingQuarantineRemovalConfirmationDialog = true
                            } label: {
                                Text("action.remove-quarantine")
                            }
                        } primaryAction: {
                            NSWorkspace.shared.openApplication(at: caskApplication.url, configuration: .init())
                        }
                    }
                }
                .confirmationDialog("package-details.cask.warning.is-quarantined.confirmation.title", isPresented: $isShowingQuarantineRemovalConfirmationDialog)
                {
                    Button(role: .destructive)
                    {
                        do
                        {
                            try caskApplication.removeQuarantine()
                            
                            isShowingQuarantineRemovalConfirmationDialog = false
                        }
                        catch let quarantineRemovalError {
                            
                            isShowingQuarantineRemovalConfirmationDialog = false
                            
                            appState.showAlert(errorToShow: .couldNotRemoveQuarantine(error: quarantineRemovalError.localizedDescription))
                        }
                    } label: {
                        Text("action.remove-quarantine.for-executable-\(caskApplication.name)")
                    }
                    .keyboardShortcut(.defaultAction)
                    
                    Button(role: .cancel) {
                        isShowingQuarantineRemovalConfirmationDialog = false
                    } label: {
                        Text("action.cancel")
                    }
                    .keyboardShortcut(.cancelAction)
                } message: {
                    Text("package-details.cask.warning.is-quarantined.confirmation.explanation")
                }
            }
        }
    }
}
