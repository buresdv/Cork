//
//  Load Image from Local URL.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import Foundation
import SwiftUI

func loadImageFromLocalURL(from url: URL) -> NSImage
{
    let data: Data = try! .init(contentsOf: url)
    let nsImage: NSImage = .init(data: data)!

    return nsImage
}
