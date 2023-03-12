//
//  GroupBox Headline Group.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

struct GroupBoxHeadlineGroup: View
{
    var image: String?
    let title: String
    let mainText: String

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
                Text(title)
                Text(mainText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
    }
}
