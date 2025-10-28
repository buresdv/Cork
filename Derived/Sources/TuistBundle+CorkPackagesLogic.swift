// periphery:ignore:all
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if hasFeature(InternalImportsByDefault)
public import Foundation
#else
import Foundation
#endif
// MARK: - Swift Bundle Accessor - for SPM
private class BundleFinder {}
extension Foundation.Bundle {
/// Since CorkPackagesLogic is a static library, the bundle containing the resources is copied into the final product.
    static let module: Bundle = {
        let bundleName = "Cork_CorkPackagesLogic"
        let bundleFinderResourceURL = Bundle(for: BundleFinder.self).resourceURL
        var candidates = [
            Bundle.main.resourceURL,
            bundleFinderResourceURL,
            Bundle.main.bundleURL,
        ]
        // This is a fix to make Previews work with bundled resources.
        // Logic here is taken from SPM's generated `resource_bundle_accessors.swift` file,
        // which is located under the derived data directory after building the project.
        if let override = ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_PATH"] {
            candidates.append(URL(fileURLWithPath: override))
            // Deleting derived data and not rebuilding the frameworks containing resources may result in a state
            // where the bundles are only available in the framework's directory that is actively being previewed.
            // Since we don't know which framework this is, we also need to look in all the framework subpaths.
            if let subpaths = try? Foundation.FileManager.default.contentsOfDirectory(atPath: override) {
                for subpath in subpaths {
                    if subpath.hasSuffix(".framework") {
                        candidates.append(URL(fileURLWithPath: override + "/" + subpath))
                    }
                }
            }
        }

        // This is a fix to make unit tests work with bundled resources.
        // Making this change allows unit tests to search one directory up for a bundle.
        // More context can be found in this PR: https://github.com/tuist/tuist/pull/6895
        #if canImport(XCTest)
        candidates.append(bundleFinderResourceURL?.appendingPathComponent(".."))
        #endif

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named Cork_CorkPackagesLogic")
    }()
}
// MARK: - Objective-C Bundle Accessor
@objc
public class CorkPackagesLogicResources: NSObject {
@objc public class var bundle: Bundle {
    return .module
}
}
// swiftformat:enable all
// swiftlint:enable all