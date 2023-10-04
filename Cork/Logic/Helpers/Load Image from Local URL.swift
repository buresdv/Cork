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
    let data = try! Data(contentsOf: url)
    let nsImage = NSImage(data: data)!

    return nsImage
}
