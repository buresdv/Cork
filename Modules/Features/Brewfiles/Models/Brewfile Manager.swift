//
//  Brewfile Manager.swift
//  Cork
//
//  Created by David Bureš - P on 11.03.2026.
//

import Foundation
import CorkShared
import FactoryKit
import SwiftUI

@Observable
public class BrewfileManager
{
    public enum BrewfileExportStage: View
    {
        case exporting
        case finished(withBrewbakFile: BrewbakFile)
        case erroredOut(withError: BrewfileDumpingError)

        public var body: some View
        {
            switch self
            {
            case .exporting:
                ExportingView()
            case .finished(let brewbakFile):
                FinishedView(brewbakFile: brewbakFile)
            case .erroredOut(let errors):
                ErroredOutView(error: errors)
            }
        }
    }
    
    public var exportStage: BrewfileExportStage
    
    public func openExportSheet()
    {
        self.exportStage = .exporting
    }
    
    public init()
    {
        self.exportStage = .exporting
    }
}
