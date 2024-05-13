//
//  Gauge - Mini Gauge.swift
//  Cork
//
//  Created by David Bureš on 13.05.2024.
//

import Foundation
import SwiftUI

struct MiniGaugeStyle: GaugeStyle
{
    
    let tint: Color
    
    func makeBody(configuration: Configuration) -> some View
    {
        ZStack
        {
            Circle()
                .stroke(
                    tint.opacity(0.5),
                    lineWidth: 10
                )
            Circle()
                .trim(from: 0, to: 1 * configuration.value)
                .stroke(
                    tint.opacity(0.5),
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: configuration.value)
        }
        .frame(width: 30, height: 30)
    }
}
