//
//  Sheet Templace.swift
//  Cork
//
//  Created by David Bureš - P on 24.01.2025.
//

import SwiftUI

struct SheetTemplate<Content: View>: View
{
    var isShowingTitle: Bool

    // Store a closure that builds the content rather than a stored @ViewBuilder property
    private let content: () -> Content

    // Provide a @ViewBuilder initializer so call sites can pass trailing closure content naturally
    init(isShowingTitle: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.isShowingTitle = isShowingTitle
        self.content = content
    }

    var body: some View
    {
        content()
            .toolbar(.hidden, for: isShowingTitle ? .automatic : .windowToolbar)
            .padding()
            .frame(minWidth: 300)
    }
}

