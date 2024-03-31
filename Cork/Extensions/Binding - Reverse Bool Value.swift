//
//  Binding - Reverse Bool Value.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import Foundation
import SwiftUI

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}
