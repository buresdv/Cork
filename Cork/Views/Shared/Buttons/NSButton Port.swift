//
//  NSButton Port.swift
//  Cork
//
//  Created by David Bureš on 17.07.2024.
//

import AppKit
import Foundation
import SwiftUI

struct SUIButton: NSViewRepresentable
{
    var label: LocalizedStringKey
    var action: () -> Void

    private var buttonStyle: NSButton.BezelStyle = .push

    typealias NSViewType = NSButton

    init(label: LocalizedStringKey, action: @escaping () -> Void)
    {
        self.label = label
        self.action = action
    }

    class Coordinator: NSObject
    {
        var parent: SUIButton
        init(_ parent: SUIButton)
        {
            self.parent = parent
        }

        @objc func buttonClicked(_: Any?)
        {
            parent.action()
        }
    }

    func makeNSView(context: Context) -> NSButton
    {
        let button: NSButton = {
            let button: NSButton = .init()

            if buttonStyle == .disclosure || buttonStyle == .pushDisclosure
            {
                button.setButtonType(.pushOnPushOff)
            }
            button.bezelStyle = buttonStyle

            button.target = context.coordinator
            button.action = #selector(Coordinator.buttonClicked)

            button.title = label.stringValue() ?? ""

            return button
        }()

        return button
    }

    func updateNSView(_ nsView: NSButton, context _: Context)
    {
        nsView.title = label.stringValue() ?? ""
        nsView.bezelStyle = buttonStyle
    }

    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }

    // MARK: - View Modifiers

    func buttonStyle(_ appKitButtonStyle: NSButton.BezelStyle) -> SUIButton
    {
        var view = self
        view.buttonStyle = appKitButtonStyle
        return view
    }
}
