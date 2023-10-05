//
//  Array - Prepend.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import Foundation

extension Array
{
    mutating func prepend(_ element: Element)
    {
        return self.insert(element, at: 0)
    }
}
