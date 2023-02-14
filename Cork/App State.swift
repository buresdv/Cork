//
//  AppState.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation

class AppState: ObservableObject {
    @Published var isShowingUninstallSheet: Bool = false
    
    @Published var isShowingUninstallationProgressView: Bool = false
    @Published var isShowingUninstallationNotPossibleDueToDependencyAlert: Bool = false
    @Published var offendingDependencyProhibitingUninstallation: String = ""
    
    @Published var isLoadingFormulae: Bool = true
    @Published var isLoadingCasks: Bool = true
}
