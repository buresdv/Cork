//
//  Open Package Detail Button.swift
//  Cork
//
//  Created by David Bureš - P on 24.05.2026.
//

import FactoryKit
import SwiftUI
import CorkModels

struct OpenPackageDetailButton: View
{
    @InjectedObservable(\.navigationManager) var navigationManager
    
    let packageToOpenDetailFor: BrewPackage

    var body: some View
    {
        Button
        {
            navigationManager.openedScreen = .package(package: packageToOpenDetailFor)
        } label: {
            Text("action.open-detail-for-\(packageToOpenDetailFor.name(withPrecision: .inlineFormatted))")
        }
    }
}
