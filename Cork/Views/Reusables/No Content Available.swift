//
//  No Content Available.swift
//  Cork
//
//  Created by David Bureš on 30.03.2024.
//

import Foundation
import SwiftUI

struct NoContentAvailableView: View
{
    let title: LocalizedStringKey
    let systemImage: String
    let description: Text? = nil
    
    var body: some View
    {
        // TODO: Implement a ContentUnavailableView here once it stops throwing `AttributeGraph: cycle detected through attribute`
        VStack(alignment: .center, spacing: 10)
        {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            
            Text(title)
                .font(.title)
                .multilineTextAlignment(.center)
            
            description
        }
        .foregroundColor(.gray)
        .fillAvailableSpace()
    }
}
