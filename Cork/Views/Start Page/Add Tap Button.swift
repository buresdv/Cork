//
//  Add Tap Button.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 14/02/2023.
//

import Foundation
import SwiftUI

struct AddTapButton: View {
    var body: some View {
        Button
        {
            isShowingTapSheet.toggle()
        } label: {
            Label
            {
                Text("Add Tap")
            } icon: {
                Image(systemName: "spigot.fill")
            }
        }
    }
}
