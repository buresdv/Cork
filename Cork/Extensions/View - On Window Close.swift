//
//  View - On Window Close.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation
import SwiftUI

extension View
{
    func onWindowClose(action: @escaping () -> Void) -> some View
    {
        self
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification), perform: { _ in
                action()
            })
    }
}
