//
//  AsyncButton - Plain Style.swift
//  Cork
//
//  Created by David Bureš - P on 25.01.2025.
//

import SwiftUI
import ButtonKit

/// Style that doesn' change the text of the button, and disables it when the async operation is in progress
struct PlainAsyncButtonStyle: AsyncButtonStyle
{
    init() {}
    
    func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
            .disabledWhenLoading()
            .asyncButtonStyle(.none)
    }
}

extension AsyncButtonStyle where Self == PlainAsyncButtonStyle
{
    static var plainStyle: PlainAsyncButtonStyle
    {
        PlainAsyncButtonStyle()
    }
}
