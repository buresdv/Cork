//
//  GroupBox Headline Group.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import SwiftUI

struct GroupBoxHeadlineGroup: View {
    
    @State var title: String
    @State var mainText: String
    
    var body: some View {
        VStack(alignment: .leading)
        {
            Text(title)
                .font(.headline)
            Text(mainText)
        }
    }
}
