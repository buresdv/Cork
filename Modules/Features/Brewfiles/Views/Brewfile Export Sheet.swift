//
//  Brewfile Export Sheet.swift
//  Cork
//
//  Created by David Bureš - P on 29.03.2026.
//

import FactoryKit
import SwiftUI

public struct BrewfileExportSheet: View
{
    @InjectedObservable(\.brewfileManager) var brewfileManager: BrewfileManager

    public var body: some View
    {
        brewfileManager.exportStage.body
            .padding()
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

    func performStageAction() async
    {
        do
        {
            let brewbakFile: BrewbakFile = try await brewfileManager.exportBrewfile()
            
            brewfileManager.exportStage = .finished(withBrewbakFile: brewbakFile)
        }
        catch let brewfileExportError
        {
            brewfileManager.exportStage = .erroredOut(withError: brewfileExportError)
        }
    }
}

struct FinishedView: View
{
    let brewbakFile: BrewbakFile

    var body: some View
    {
        BrewfileIconProxy(brewbak: brewbakFile)
    }
}

struct ErroredOutView: View
{
    let error: BrewfileManager.BrewfileDumpingError

    var body: some View
    {
        switch error
        {
        case .couldNotDetermineWorkingDirectory:
            Text(BrewfileManager.BrewfileDumpingError.couldNotDetermineWorkingDirectory.localizedDescription)
        case .errorWhileDumpingBrewfile(let error):
            Text(error)
        case .couldNotReadBrewfile(let error):
            Text(error)
        }
    }
}
