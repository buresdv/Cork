//
//  Trustable.swift
//  Cork
//
//  Created by David Bureš - P on 28.08.2026.
//

import Foundation

/// Whether this resource is trusted implicitly, or required explicit trust to be set
public enum TrustType: Sendable, Codable, Hashable
{
    /// Resource is implicitly trusted, reserved for first-party resources
    case implicit
    /// Resource requires explicit trust
    case explicit(TrustValue?)
}

/// Whether this resource is actually trusted
public enum TrustValue: Sendable, Codable, Hashable
{
    /// Resource is trusted and unrestricted
    case trusted
    
    /// Resource is not trusted and is restricted
    case untrusted
}

public protocol Trustable: Actor
{
    /// Whether this resource is trusted
    ///
    /// Possible values:
    /// - `implicit`: resource is trusted implicitly, reserved for first-party resources, like `homebrew/(tap)` taps
    /// - `explicit`: resource is trusted explicitly, for everything else
    ///     - `trusted`: resource was explicitly marked as trusted
    ///     - `untrusted`: resource is not explicitly trusted, therefore it is not trusted
    var isTrusted: TrustType? { get set }
    
    func changeTrust(to newTrustValue: TrustType) async
}

public extension Trustable
{
    func changeTrust(to newTrustValue: TrustType) async
    {
        self.isTrusted = newTrustValue
    }
}
