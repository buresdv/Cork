//
//  Complex with Icon.swift
//  Cork
//
//  Created by David Bureš on 13.02.2023.
//

import SwiftUI

struct ComplexWithIcon<Content: View>: View
{
    let systemName: String

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
    let imageName: NSImage.Name

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

struct ComplexWithImage<Content: View>: View 
{
    
    let image: Image
    
    @ViewBuilder var content: Content
    
    var body: some View 
    {
        HStack(alignment: .top, spacing: 10)
        {
            image
                .resizable()
                .frame(width: 75, height: 75)
                .foregroundColor(.secondary)

            content
        }
    }
}
