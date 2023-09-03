//
//  Inline Fatal Error.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation
import SwiftUI

struct InlineFatalError: View
{

    let errorMessage: LocalizedStringKey

    var body: some View
    {
        VStack(alignment: .center, spacing: 10)
        {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
            //.scaledToFit()
            Text(errorMessage)
            Button {
                restartApp()
            } label: {
                Text("action.restart")
            }
        }
        .foregroundColor(.gray)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
