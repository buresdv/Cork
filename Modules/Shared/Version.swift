//
//  Version.swift
//  CorkShared
//
//  Created by Stéphane Copin on 19.04.2025.
//  https://gist.github.com/stephanecopin/887448c4e955c2612508dd84545c9003

import Foundation


private struct Version
{
    let major: UInt
    let minor: UInt
    let patch: UInt?

    init(major: UInt, minor: UInt = 0, patch: UInt? = nil)
    {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    init?(versionString: String)
    {
        let splitVersion = versionString.split(separator: ".")
        switch splitVersion.count
        {
        case 0:
            return nil
        case 1:
            guard let major = UInt(splitVersion[0])
            else
            {
                return nil
            }
            self.init(major: major)
        case 2:
            guard
                let major = UInt(splitVersion[0]),
                let minor = UInt(splitVersion[1])
            else
            {
                return nil
            }
            self.init(major: major, minor: minor)
        default:
            guard
                let major = UInt(splitVersion[0]),
                let minor = UInt(splitVersion[1]),
                let patch = UInt(splitVersion[2])
            else
            {
                return nil
            }
            self.init(major: major, minor: minor, patch: patch)
        }
    }
}

extension Version: CustomStringConvertible
{
    public var description: String
    {
        var description = "\(self.major).\(self.minor)"
        if let patch
        {
            description += ".\(patch)"
        }
        return description
    }
}

extension Version: Equatable
{
    public static func == (lhs: Version, rhs: Version) -> Bool
    {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

extension Version: Hashable
{
    public func hash(into hasher: inout Hasher)
    {
        major.hash(into: &hasher)
        minor.hash(into: &hasher)
        patch.hash(into: &hasher)
    }
}

extension Version: Comparable
{
    public static func < (lhs: Version, rhs: Version) -> Bool
    {
        (
            lhs.major,
            lhs.minor,
            lhs.patch ?? 0
        ) < (
            rhs.major,
            rhs.minor,
            rhs.patch ?? 0
        )
    }
}
