//
//  Brewfile Export Sheet.swift
//  Cork
//
//  Created by David Bureš - P on 29.03.2026.
//

import FactoryKit
import SwiftUI
import CorkShared

public struct BrewfileExportSheet: View
{
    @InjectedObservable(\.brewfileManager) var brewfileManager: BrewfileManager

    public init()
    {
        brewfileManager.exportStage = .exporting
    }
    
    public var body: some View
    {
        NavigationStack
        {
            brewfileManager.exportStage.body
                .padding()
                .navigationTitle("brewfile.export.title")
        }
    }
}

struct ExportingView: View
{
    @InjectedObservable(\.brewfileManager) var brewfileManager: BrewfileManager

    var body: some View
    {
        HStack(alignment: .center, spacing: 20)
        {
            ProgressView()

            Text("brewfile.export.progress")
        }
        .task
        {
            await performStageAction()
        }
    }

    @MainActor
    func performStageAction() async
    {
        do
        {
            let brewbakFile: BrewbakFile = try await brewfileManager.exportBrewfile()
            
            brewfileManager.exportStage = .finished(withBrewbakFile: brewbakFile)
        }
        catch let brewfileExportError
        {
            AppConstants.shared.logger.error("Caught error from export function: \(brewfileExportError)")
            brewfileManager.exportStage = .erroredOut(withError: brewfileExportError)
        }
    }
}

struct FinishedView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    
    let brewbakFile: BrewbakFile

    var body: some View
    {
        HStack(alignment: .top, spacing: 10)
        {
            BrewfileIconProxy(brewbak: brewbakFile)
            
            VStack(alignment: .leading)
            {
                Text("brewfile.export.success.title")
                    .font(.headline)
                Text("brewfile.export.success.instructions")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("action.close")
                }

            }
        }
    }
}

struct ErroredOutView: View
{
    let error: BrewfileManager.BrewfileDumpingError

    var body: some View
    {
        
        HStack(alignment: .top, spacing: 10)
        {
            Image(systemName: "xmark.seal")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.secondary)

            VStack(alignment: .leading)
            {
                Text("error.brewfile.export.could-not-dump")
                    .font(.headline)
                
                switch error
                {
                case .couldNotDetermineWorkingDirectory:
                    Text(BrewfileManager.BrewfileDumpingError.couldNotDetermineWorkingDirectory.localizedDescription)
                case .errorWhileDumpingBrewfile(let errors):
                    List(errors, id: \.self)
                    { error in
                        Text(error)
                    }
                    .listStyle(.bordered)
                    .alternatingRowBackgrounds()
                    .frame(minHeight: 200)
                case .couldNotReadBrewfile(let error):
                    Text(error)
                }
            }
        }
    }
}
