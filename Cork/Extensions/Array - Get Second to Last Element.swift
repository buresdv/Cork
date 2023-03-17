//
//  Array - Get Second to Last Element.swift
//  Cork
//
//  Created by David Bureš on 17.03.2023.
//

import Foundation

extension Array
{
    func penultimate() -> Element?
    {
        if count < 2
        {
            return nil
        }
        let index = count - 2
        return self[index]
    }
}
