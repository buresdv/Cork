//
//  Markable.swift
//  Cork
//
//  Created by David Bureš - P on 07.01.2026.
//

import Foundation

// TODO: Implement this for the right objects (like OutdatedPackage)
/// Protocol providing boilerplate for marking something as either selected or not selectd
protocol Selectable: AnyObject
{
    var isSelected: Bool { get set }
    
    func setSelectedState(to newState: Bool?)
}

extension Selectable
{
    func setSelectedState(to newState: Bool? = nil)
    {
        if let newState
        {
            self.isSelected = newState
        }
        else
        {
            self.isSelected.toggle()
        }
    }
}
