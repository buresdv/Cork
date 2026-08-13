//
//  Status Pill.swift
//  CorkShared
//
//  Created by David Bureš - P on 12.08.2026.
//

import SwiftUI

struct StatusPill: View
{
    var localizedText: LocalizedStringKey

    var systemImage: String
    
    var color: Color

    var body: some View
    {
        Label(localizedText, systemImage: systemImage)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(color)
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(color, lineWidth: 1))
    }
}
