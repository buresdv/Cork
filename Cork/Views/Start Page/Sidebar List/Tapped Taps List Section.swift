//
//  Tapped Taps List Section.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 12/02/2023.
//

import Foundation
import SwiftUI

struct TappedTapsListSection: View {
    @Binding var tappedTaps: [BrewTap]
    
    var body: some View {
        Section("Tapped Taps")
        {
            if !tappedTaps.isEmpty
            {
                ForEach(tappedTaps)
                { tap in
                    Text(tap.name)
                }
            }
            else
            {
                ProgressView()
            }
        }
        .collapsible(false)
    }
}
