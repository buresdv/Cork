//
//  AddFormulaeButton.swift
//  Cork
//
//  Created by Manuel Lorenzo Parejo on 14/02/2023.
//

import Foundation
import SwiftUI

struct AddFormulaeButton: View {
    var body: some View {
        Button
        {
            isShowingInstallSheet.toggle()
        } label: {
            Label
            {
                Text("Add Formula")
            } icon: {
                Image(systemName: "plus")
            }
        }
    }
}
