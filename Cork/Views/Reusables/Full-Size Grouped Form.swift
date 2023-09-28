//
//  Full-Size Grouped Form.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct FullSizeGroupedForm<Content: View>: View {

    @ViewBuilder var content: Content

    var body: some View {
        Form
        {
            content
        }
        .formStyle(.grouped)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding(-20)
        .scrollContentBackground(.hidden)
    }
}

