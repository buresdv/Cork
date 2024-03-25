//
//  Services Tracker.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation

@MainActor
class ServicesTracker: ObservableObject
{
    @Published var services: Set<HomebrewService> = .init()
}
