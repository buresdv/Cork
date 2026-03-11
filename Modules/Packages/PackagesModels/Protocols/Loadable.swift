//
//  Loadable.swift
//  Cork
//
//  Created by David Bureš - P on 11.03.2026.
//

import Foundation
import SwiftUI

/// Designate object as Loadable - whether it takes time to load, and displaying its loading state in the UI
public protocol Loadable: AnyObject
{
    associatedtype LoadingView: View
    
    /// Whether the object is being currently loaded
    var isBeingLoaded: Bool { get set }
    
    /// The view that will get displayed when the object is being loaded
    static var loadingView: LoadingView { get }
}

/// Designate Actor as Loadable - whether it takes time to load, and displaying its loading state in the UI
public protocol LoadableActor: Actor
{
    associatedtype LoadingView: View
    
    /// Whether the object is being currently loaded
    var isBeingLoaded: Bool { get set }
    
    /// The view that will get displayed when the object is being loaded
    static var loadingView: LoadingView { get }
}

public extension LoadableActor
{
    func setBeingLoadedStatus(to loadingStatus: Bool)
    {
        self.isBeingLoaded = loadingStatus
    }
}
