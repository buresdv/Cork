//
//  Inline Content Unavailable View.swift
//  Cork
//
//  Created by David Bureš - P on 14.04.2025.
//

import SwiftUI

struct InlineContentUnavailableView: View
{
    let label: LocalizedStringKey
    let image: String
    
    var body: some View
    {
        HStack(alignment: .center, spacing: 5)
        {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
                .foregroundStyle(.tertiary)
            
            Text(label)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

struct SmallerContentUnavailableView: View
{
    let label: LocalizedStringKey
    let image: String
    
    var body: some View
    {
        VStack(alignment: .center, spacing: 5)
        {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .foregroundStyle(.tertiary)
            
            Text(label)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    InlineContentUnavailableView(label: "add-package.search.results.casks.none-found", image: "custom.macwindow.badge.magnifyingglass")
}
