//
//  DateStyle - AppStorage Support.swift
//  Cork
//
//  Created by David Bureš - P on 17.04.2025.
//

import Foundation
import SwiftUI

extension Date.FormatStyle.DateStyle: @retroactive RawRepresentable, @retroactive Identifiable, @retroactive CaseIterable
{
    public typealias RawValue = Int

    public init?(rawValue: Int)
    {
        switch rawValue
        {
        case 0: self = .abbreviated
        case 1: self = .complete
        case 2: self = .long
        case 3: self = .numeric
        case 4: self = .omitted
        default: return nil
        }
    }

    public var rawValue: Int
    {
        switch self
        {
        case .abbreviated:
            return 0
        case .complete:
            return 1
        case .long:
            return 2
        case .numeric:
            return 3
        case .omitted:
            return 4
        default:
            return 0
        }
    }
    
    var localizedDescription: LocalizedStringKey
    {
        switch self
        {
        case .abbreviated:
            return "settings.general.backup-number-style.abbreviated"
        case .complete:
            return "settings.general.backup-number-style.complete"
        case .long:
            return "settings.general.backup-number-style.long"
        case .numeric:
            return "settings.general.backup-number-style.numeric"
        case .omitted:
            return "settings.general.backup-number-style.omitted"
        default:
            return "settings.general.backup-number-style.abbreviated"
        }
    }
    
    public static var allCases: [Date.FormatStyle.DateStyle] {
        return [.abbreviated, .complete, .long, .numeric, .omitted]
    }
    
    public var id: Self { self }
}
