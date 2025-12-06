//
//  Reveal in Finder Button.swift
//  Cork
//
//  Created by David Bureš - Virtual on 12.06.2025.
//

import SwiftUI
import Defaults
import CorkModels

struct RevealPackageInFinderButton: View
{
    @Default(.enableRevealInFinder) var enableRevealInFinder: Bool
    
    @Environment(AppState.self) var appState: AppState
    
    let package: BrewPackage
    
    let customLabel: LocalizedStringKey? = nil
    
    var body: some View
    {
        if enableRevealInFinder
        {
            Button
            {
                do
                {
                    try package.revealInFinder()
                } catch {
                    appState.showAlert(errorToShow: .couldNotFindPackageInParentDirectory)
                }
            } label: {
                RevealInFinderButtonLabel(customLabel: customLabel)
            }
        }
    }
}

struct RevealServiceInFinderButton: View
{
    @Default(.enableRevealInFinder) var enableRevealInFinder: Bool
    
    let service: HomebrewService
    
    let customLabel: LocalizedStringKey? = nil
    
    var body: some View
    {
        if enableRevealInFinder
        {
            Button
            {
                service.revealInFinder()
            } label: {
                RevealInFinderButtonLabel(customLabel: customLabel)
            }
        }
    }
}

struct RevealInFinderButtonWithArbitraryAction: View
{
    @Default(.enableRevealInFinder) var enableRevealInFinder: Bool
    
    let customLabel: LocalizedStringKey? = nil
    
    let action: () -> Void
    
    var body: some View
    {
        if enableRevealInFinder
        {
            Button
            {
                action()
            } label: {
                RevealInFinderButtonLabel(customLabel: customLabel)
            }
        }
    }
}

private struct RevealInFinderButtonLabel: View
{
    let customLabel: LocalizedStringKey?
    
    var body: some View
    {
        if let customLabel
        {
            Label(customLabel, systemImage: "finder")
        }
        else
        {
            Label("action.reveal-in-finder", systemImage: "finder")
        }
    }
}
