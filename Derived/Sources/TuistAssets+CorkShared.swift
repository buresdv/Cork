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

public enum CorkSharedAsset: Sendable {
  public enum Assets {
  public static let accentColor = CorkSharedColors(name: "AccentColor")
    public static let customAppleTerminalBadgeMagnifyingglass = CorkSharedImages(name: "custom.apple.terminal.badge.magnifyingglass")
    public static let customBrainSlash = CorkSharedImages(name: "custom.brain.slash")
    public static let customMacwindowBadgeMagnifyingglass = CorkSharedImages(name: "custom.macwindow.badge.magnifyingglass")
    public static let customMacwindowBadgeXmark = CorkSharedImages(name: "custom.macwindow.badge.xmark")
    public static let customPinFillQuestionmark = CorkSharedImages(name: "custom.pin.fill.questionmark")
    public static let customShippingbox2BadgeArrowDown = CorkSharedImages(name: "custom.shippingbox.2.badge.arrow.down")
    public static let customShippingboxBadgeMagnifyingglass = CorkSharedImages(name: "custom.shippingbox.badge.magnifyingglass")
    public static let customShippingboxBadgePlus = CorkSharedImages(name: "custom.shippingbox.badge.plus")
    public static let customSparklesSlash = CorkSharedImages(name: "custom.sparkles.slash")
    public static let customSpigotBadgePlus = CorkSharedImages(name: "custom.spigot.badge.plus")
    public static let customSpigotBadgeXmark = CorkSharedImages(name: "custom.spigot.badge.xmark")
    public static let customSquareStackBadgePause = CorkSharedImages(name: "custom.square.stack.badge.pause")
    public static let customSquareStackBadgePlay = CorkSharedImages(name: "custom.square.stack.badge.play")
    public static let customSquareStackBadgeQuestionmark = CorkSharedImages(name: "custom.square.stack.badge.questionmark")
    public static let customSquareStackTrianglebadgeExclamationmark = CorkSharedImages(name: "custom.square.stack.trianglebadge.exclamationmark")
    public static let customTerminalBadgeXmark = CorkSharedImages(name: "custom.terminal.badge.xmark")
    public static let customTrashTriangleFill = CorkSharedImages(name: "custom.trash.triangle.fill")
  }
  public enum PreviewAssets {
  }
}

// MARK: - Implementation Details

public final class CorkSharedColors: Sendable {
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

public extension CorkSharedColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: CorkSharedColors) {
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
  init(asset: CorkSharedColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct CorkSharedImages: Sendable {
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
  init(asset: CorkSharedImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: CorkSharedImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: CorkSharedImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
