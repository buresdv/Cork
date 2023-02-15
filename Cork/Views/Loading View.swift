//
//  Loading View.swift
//  Cork
//
//  Created by David Bureš on 09.07.2022.
//

import SwiftUI

struct LoadingView: View
{
    var body: some View
    {
        HStack
        {
            ProgressView()
                .scaleEffect(0.5)
            Text("Loading package info...")
        }
        .foregroundColor(.gray)
    }
}
