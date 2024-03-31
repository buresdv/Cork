//
//  Services State.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation

@MainActor
class ServicesState: ObservableObject
{
    // MARK: - Navigation
    @Published var navigationSelection: UUID?
    
    // MARK: - State
    @Published var isLoadingServices: Bool = true
}
