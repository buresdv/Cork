//
//  GroupBox Headline Group.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

struct GroupBoxHeadlineGroup: View {
    
    var title: String
    var mainText: String
    
    var body: some View {
        VStack(alignment: .leading)
        {
            Text(title)
            Text(mainText)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
