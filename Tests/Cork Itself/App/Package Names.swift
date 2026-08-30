//
//  Package Names.swift
//  CorkTerminalFunctionsTests
//
//  Created by David Bureš - P on 25.08.2026.
//

import CorkModels
import Testing

@Suite("Package Name Handling")
struct PackageNameHandling
{
    @Test("Parse simple package name")
    func simplePackageNameParsing() async throws
    {
        let rawName: String = "cork"
        
        let parsedName: BrewPackageName = .init(from: rawName)
        
        #expect(parsedName.packageTap == nil)
        #expect(parsedName.packageIdentifier == "cork")
        #expect(parsedName.boundVersion == nil)
    }

    @Test("Parse simple package name with a bound version")
    func packageThatIncludesBoundVersionParsing() async throws
    {
        let rawName: String = "cork@beta"
        
        let parsedName: BrewPackageName = .init(from: rawName)
        
        #expect(parsedName.packageTap == nil)
        #expect(parsedName.packageIdentifier == "cork")
        #expect(parsedName.boundVersion == "beta")
    }

    @Test("Parse package name that includes tap")
    func packageNameThatIncludesTapParsing() async throws
    {
        let rawName: String = "marsanne/cask/cork"
        
        let parsedName: BrewPackageName = .init(from: rawName)
        
        #expect(parsedName.packageTap == .init(repo: .external(name: "marsanne"), tapName: "cask"))
        #expect(parsedName.packageIdentifier == "cork")
        #expect(parsedName.boundVersion == nil)
    }

    @Test("Parse package name tha includes tap & bound version")
    func packageNameThatIncludesTapAndBoundVersion() async throws
    {
        let rawName: String = "marsanne/cask/cork@beta"
        
        let parsedName: BrewPackageName = .init(from: rawName)
        
        #expect(parsedName.packageTap == .init(repo: .external(name: "marsanne"), tapName: "cask"))
        #expect(parsedName.packageIdentifier == "cork")
        #expect(parsedName.boundVersion == "beta")
    }
}
