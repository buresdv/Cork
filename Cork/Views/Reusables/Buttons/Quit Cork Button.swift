//
//  Quit Cork Button.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct QuitCorkButton: View
{
    var body: some View
    {
        Button("action.quit")
        {
            NSApp.terminate(self)
        }
    }
}
