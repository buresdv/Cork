//
//  App Constants.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

struct AppConstants { // Had to add "local" because my package already has a struct called "AppConstants"
    static let brewCellarPath: URL = URL(string: "/opt/homebrew/Cellar")!
    static let brewCaskPath: URL = URL(string: "/opt/homebrew/Caskroom")!
}
