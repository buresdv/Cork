// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - Asset Catalogs

public enum CorkAsset: Sendable {
  public enum Assets {
  public static let accentColor = CorkColors(name: "AccentColor")
    public static let customAppleTerminalBadgeMagnifyingglass = CorkImages(name: "custom.apple.terminal.badge.magnifyingglass")
    public static let customBrainSlash = CorkImages(name: "custom.brain.slash")
    public static let customMacwindowBadgeMagnifyingglass = CorkImages(name: "custom.macwindow.badge.magnifyingglass")
    public static let customMacwindowBadgeXmark = CorkImages(name: "custom.macwindow.badge.xmark")
    public static let customPinFillQuestionmark = CorkImages(name: "custom.pin.fill.questionmark")
    public static let customShippingboxBadgeMagnifyingglass = CorkImages(name: "custom.shippingbox.badge.magnifyingglass")
    public static let customShippingboxBadgePlus = CorkImages(name: "custom.shippingbox.badge.plus")
    public static let customSparklesSlash = CorkImages(name: "custom.sparkles.slash")
    public static let customSpigotBadgePlus = CorkImages(name: "custom.spigot.badge.plus")
    public static let customSpigotBadgeXmark = CorkImages(name: "custom.spigot.badge.xmark")
    public static let customSquareStackBadgePause = CorkImages(name: "custom.square.stack.badge.pause")
    public static let customSquareStackBadgePlay = CorkImages(name: "custom.square.stack.badge.play")
    public static let customSquareStackBadgeQuestionmark = CorkImages(name: "custom.square.stack.badge.questionmark")
    public static let customSquareStackTrianglebadgeExclamationmark = CorkImages(name: "custom.square.stack.trianglebadge.exclamationmark")
    public static let customTerminalBadgeXmark = CorkImages(name: "custom.terminal.badge.xmark")
    public static let customTrashTriangleFill = CorkImages(name: "custom.trash.triangle.fill")
  }
  public enum PreviewAssets {
  }
}

// MARK: - Implementation Details

public final class CorkColors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension CorkColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: CorkColors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: CorkColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct CorkImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: CorkImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: CorkImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: CorkImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
