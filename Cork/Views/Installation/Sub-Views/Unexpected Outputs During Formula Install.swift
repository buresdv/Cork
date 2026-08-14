//
//  Unexpected Outputs During Foirmula Install.swift
//  Cork
//
//  Created by David Bureš - P on 12.08.2026.
//

import SwiftUI
import CorkShared
import CorkModels
import CorkTerminalFunctions

struct UnexpectedOutputsDuringPackageInstall: View
{
    let unexpectedOutputType: PackageInstallationProcessSteps.UnexpectedTerminalOutputType
    
    let installationProgressTracker: InstallationProgressTracker
    
    var body: some View
    {
        switch unexpectedOutputType
        {
        case .containedErrors(let rawOutput):
            ContainedErrors(
                outputs: rawOutput,
                installationProgressTracker: installationProgressTracker
            )
        case .didNotContainErrors(let rawOutput):
            DidNotContainErrors(
                outputs: rawOutput,
                installationProgressTracker: installationProgressTracker
            )
        }
    }
}

private struct DidNotContainErrors: View {
    
    let outputs: [TerminalOutput]
    
    let installationProgressTracker: InstallationProgressTracker
    
    @State private var isExpanded: Bool = true
    
    var body: some View {
        ComplexWithImage(image: .init(systemName: "checkmark.seal.text.page"))
        {
            HeadlineWithArbitraryContent(headline: "add-package.\(installationProgressTracker.packageToInstall.name(withPrecision: .inlineFormatted)).probably-installed.no-errors.title") {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("add-package.probably-installed.no-errors.description")
                    
                    DisclosureGroup("add-package.error.unimplemented-outputs.dropdown.label", isExpanded: $isExpanded) {
                        outputs.outputView
                    }
                }
            }
        }
    }
}

private struct ContainedErrors: View {

    let outputs: [TerminalOutput]
    
    let installationProgressTracker: InstallationProgressTracker
    
    @State private var isExpanded: Bool = true
    
    var body: some View {
        ComplexWithImage(image: .init(systemName: "info.circle.text.page"))
        {
            HeadlineWithArbitraryContent(headline: "add-package.\(installationProgressTracker.packageToInstall.name(withPrecision: .inlineFormatted)).probably-installed.had-errors.title")
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("add-package.probably-installed.had-errors.description")
                    
                    DisclosureGroup("add-package.error.unimplemented-outputs.dropdown.label", isExpanded: $isExpanded) {
                        outputs.outputView
                    }
                }
            }
        }
    }
}
