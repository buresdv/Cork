//
//  Restart Cork Button.swift
//  Cork
//
//  Created by David Bureš on 31.05.2024.
//

import SwiftUI

struct RestartCorkButton: View
{
    var body: some View
    {
        Button
        {
            restartApp()
        } label: {
            Text("action.restart")
        }
    }
}
