//
//  Shell Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func shell(_ launchPath: String, _ arguments: [String]) async -> TerminalOutput
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    
    let errorPipe = Pipe()
    task.standardError = errorPipe
    
    do
    {
        try task.run()
    }
    catch
    {
        print(error)
    }

    let standardOutput = pipe.fileHandleForReading.readDataToEndOfFile()
    let standardError = errorPipe.fileHandleForReading.readDataToEndOfFile()
    
    let finalOutput = String(data: standardOutput, encoding: .utf8) ?? ""
    let finalError = String(data: standardError, encoding: .utf8) ?? ""
    
    return TerminalOutput(standardOutput: finalOutput, standardError: finalError)
}
