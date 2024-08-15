//
//  Subtitle Text.swift
//  Cork
//
//  Created by David Bureš on 22.11.2023.
//

import SwiftUI

struct SubtitleText: View
{
    let text: LocalizedStringKey

    var body: some View
    {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.gray)
    }
}
