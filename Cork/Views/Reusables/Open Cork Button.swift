//
//  Open Cork Button.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import SwiftUI

struct OpenCorkButton: View {
    
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        Button("menubar.open.cork")
        {
            openWindow(id: "main")
            
            switchCorkToForeground()
        }
    }
}

