//
//  Shell Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func shell(_ launchPath: String, _ arguments: [String]) async -> String?
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    do {
        try task.run()
    } catch {
        print(error)
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)

    return output
}
