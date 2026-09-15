//
//  Double Click.swift
//  Cork
//
//  Created by Joe Lekstrom - https://gist.github.com/joelekstrom/91dad79ebdba409556dce663d28e8297.
//

import Foundation
import SwiftUI

public extension View
{
    func onDoubleClick(handler: @escaping @MainActor () async -> Void) -> some View
    {
        modifier(DoubleClickHandler(handler: handler))
    }
}

struct DoubleClickHandler: ViewModifier
{
    let handler: @MainActor () async -> Void

    func body(content: Content) -> some View
    {
        content.overlay
        {
            DoubleClickListeningViewRepresentable(handler: handler)
        }
    }
}

struct DoubleClickListeningViewRepresentable: NSViewRepresentable
{
    let handler: @MainActor () async -> Void

    func makeNSView(context _: Context) -> DoubleClickListeningView
    {
        DoubleClickListeningView(handler: handler)
    }

    func updateNSView(_: DoubleClickListeningView, context _: Context) {}
}

final class DoubleClickListeningView: NSView
{
    let handler: @MainActor () async -> Void

    init(handler: @escaping @MainActor () async -> Void)
    {
        self.handler = handler
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent)
    {
        super.mouseDown(with: event)
        if event.clickCount == 2
        {
            Task {
                await handler()
            }
        }
    }
}
