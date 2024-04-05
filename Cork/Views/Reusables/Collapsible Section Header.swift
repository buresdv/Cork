//
//  Collapsible Section Header.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import SwiftUI

struct CollapsibleSectionHeader: View {
    
    let headerText: LocalizedStringKey
    
    @Binding var isCollapsed: Bool
    
    var body: some View {
        HStack(alignment: .center)
        {
            Text(headerText)
                .animation(.none, value: isCollapsed)
            
            Spacer()
            
            Button
            {
                withAnimation
                {
                    isCollapsed.toggle()
                }
            } label: {
                Text(isCollapsed ? "action.show" : "action.hide")
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(nsColor: .controlAccentColor))
        }
    }
}
