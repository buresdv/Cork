//
//  Complex with Icon.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct ComplexWithIcon<Content: View>: View
{
    @State var systemName: String

    @ViewBuilder var content: Content

    var body: some View
    {
        HStack(alignment: .top, spacing: 10)
        {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.secondary)

            content
        }
    }
}

struct ComplexWithIconWithSystemImage<Content: View>: View
{
    @State var imageName: NSImage.Name

    @ViewBuilder var content: Content

    var body: some View
    {
        HStack(alignment: .top, spacing: 10)
        {
            Image(nsImage: NSImage(named: imageName)!)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.secondary)

            content
        }
    }
}
