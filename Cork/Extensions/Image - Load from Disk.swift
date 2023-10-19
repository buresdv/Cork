//
//  Image - Load from Disk.swift
//  Cork
//
//  Created by David Bureš on 19.10.2023.
//

import Foundation
import SwiftUI
import AppKit

extension Image
{
    init?(localURL: URL) 
    {
        guard let data = try? Data(contentsOf: localURL),
              let nsImage = NSImage(data: data)
        else {
            return nil
        }
        
        self.init(nsImage: nsImage)
    }
}
