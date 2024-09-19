//
//  HelpButton.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import SwiftUI

struct HelpButton: NSViewRepresentable
{
    var action: () -> Void

    func makeNSView(context: Context) -> NSButton
    {
        let button: NSButton = {
            let button: NSButton = .init()
            button.bezelStyle = .helpButton
            button.target = context.coordinator
            button.action = #selector(Coordinator.buttonClicked)
            button.title = ""
            return button
        }()

        return button
    }

    func updateNSView(_: NSButton, context _: Context)
    {}

    typealias NSViewType = NSButton

    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }

    class Coordinator: NSObject
    {
        var parent: HelpButton
        init(_ parent: HelpButton)
        {
            self.parent = parent
        }

        @MainActor @objc func buttonClicked(_: Any?)
        {
            parent.action()
        }
    }
}
