//
//  GroupBox Headline Group.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

/// For just headline + subheadline
struct GroupBoxHeadlineGroup: View
{
    var image: String?
    let title: LocalizedStringKey
    let mainText: LocalizedStringKey

    var animateNumberChanges: Bool = false

    var body: some View
    {
        HStack(spacing: 15)
        {
            if let image
            {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
            }

            VStack(alignment: .leading, spacing: 2)
            {
                if animateNumberChanges
                {
                    Text(title)
                        .contentTransition(.numericText())
                }
                else
                {
                    Text(title)
                }
                Text(mainText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(2)
    }
}

// For any arbitrary image
struct GroupBoxHeadlineGroupWithArbitraryImage: View
{
    let image: Image
    
    let title: LocalizedStringKey
    let mainText: LocalizedStringKey
    
    var animateNumberChanges: Bool = false
    
    var body: some View
    {
        HStack(spacing: 15)
        {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
            
            VStack(alignment: .leading, spacing: 2)
            {
                if animateNumberChanges
                {
                    Text(title)
                        .contentTransition(.numericText())
                }
                else
                {
                    Text(title)
                }
                Text(mainText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(2)
    }
}

/// For any artitrary content
struct GroupBoxHeadlineGroupWithArbitraryContent<Content: View>: View
{
    var image: String?
    @ViewBuilder var content: Content

    var body: some View
    {
        HStack(alignment: .top, spacing: 15)
        {
            if let image
            {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
            }

            content
        }
        .padding(2)
    }
}
