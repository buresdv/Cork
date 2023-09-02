//
//  Updating Process Details.swift
//  Cork
//
//  Created by David Bureš on 02.09.2023.
//

import Foundation

class UpdatingProcessDetails: ObservableObject
{
    @Published var currentStage: UpdateProcessStages = .backingUp
}
