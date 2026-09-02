//
//  Open Package Detail Button.swift
//  Cork
//
//  Created by David Bureš - P on 24.05.2026.
//

import FactoryKit
import SwiftUI

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
            Label("action.open-detail-for-\(packageToOpenDetailFor.name(withPrecision: .inlineFormatted))", systemImage: "arrow.up.right")
        }
    }
}
