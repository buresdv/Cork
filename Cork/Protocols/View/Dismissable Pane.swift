//
//  Dismissable Pane.swift
//  Cork
//
//  Created by David Bureš - P on 26.07.2025.
//

import Foundation
import SwiftUI
import CorkModels
import FactoryKit

protocol DismissablePane: View
{
    /// Dismisss this pane from the detail view
    func dismissPane()
}

extension DismissablePane
{
    func dismissPane()
    {
        let navigationManager: CorkModels.NavigationManager = Container.shared.navigationManager.resolve()
        
        navigationManager.dismissScreen()
    }
}
