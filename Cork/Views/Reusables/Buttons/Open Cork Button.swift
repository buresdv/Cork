//
//  Open Cork Button.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct OpenCorkButton: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction

    var body: some View
    {
        Button("menubar.open.cork")
        {
            let activationPolicy: NSApplication.ActivationPolicy = NSApp.activationPolicy()
            
            openWindow(id: "main")

            switchCorkToForeground()
            
            if activationPolicy == .accessory
            {
                NSApp.setActivationPolicy(.regular)
            }
        }
    }
}
