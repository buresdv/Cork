//
//  Sheet Templace.swift
//  Cork
//
//  Created by David Bureš - P on 24.01.2025.
//

import SwiftUI

struct SheetTemplate<Content: View>: View
{
    var isShowingTitle: Bool
    
    @ViewBuilder var sheetContent: Content
    
    var body: some View
    {
        sheetContent
            .toolbar(.hidden, for: isShowingTitle ? .automatic : .windowToolbar)
            .padding()
            .frame(minWidth: 300)
    }
}
