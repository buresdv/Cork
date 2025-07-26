//
//  Dismissable Pane.swift
//  Cork
//
//  Created by David Bureš - P on 26.07.2025.
//

import Foundation
import SwiftUI

protocol DismissablePane: View
{
    /// Has to be loaded from the `@Environment`
    var appState: AppState { get }
    
    /// Dismisss this pane from the detail view
    func dismissPane()
}

extension DismissablePane
{
    func dismissPane()
    {
        self.appState.navigationManager.dismissScreen()
    }
}
