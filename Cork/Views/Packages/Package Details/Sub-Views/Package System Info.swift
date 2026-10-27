//
//  Package System Info.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import ApplicationInspector
import CorkModels
import FactoryKit
import SwiftUI

struct PackageSystemInfo: View
{
    @Environment(\.caskApplication) var caskApplication

    let package: BrewPackage

    @State private var isShowingCaskSizeHelpPopover: Bool = false

    var body: some View
    {
        if let installedOnDate = package.installedOn // Only show the "Installed on" date for packages that are actually installed
        {
            Section
            {
                caskInstalledAsLine

                installedOnDateLine(installedOnDate)

                if let packageSize = package.sizeInBytes
                {
                    packageSizeLine(packageSize)

                    PackageSizeInGraphView(package: package, packageSizeInBytes: packageSize)
                }
            }
        }
    }

    @ViewBuilder
    var caskInstalledAsLine: some View
    {
        if let caskApplication
        {
            LabeledContent
            {
                AppIconDisplay(
                    displayType: .asIconWithAppNameDisplayed(
                        usingApp: caskApplication,
                        namePosition: .besideAppIcon
                    ),
                    allowRevealingInFinderFromIcon: true
                )
            } label: {
                Text("package-details.installed-as")
            }
        }
    }

    @ViewBuilder
    func installedOnDateLine(_ installedOnDate: Date) -> some View
    {
        LabeledContent
        {
            Text(installedOnDate.formatted(.packageInstallationStyle))
        } label: {
            Text("package-details.install-date")
        }
    }

    @ViewBuilder
    func packageSizeLine(_ packageSize: Int64) -> some View
    {
        LabeledContent
        {
            Text(packageSize.formatted(.byteCount(style: .file)))
        } label: {
            Text("package-details.size")
        }
    }
}

import Charts

private struct PackageSizeInGraphView: View
{
    @InjectedObservable(\.appState) var appState: AppState
    
    let package: BrewPackage

    let packageSizeInBytes: Int64
    
    var sizeOfTheCorrespondingFolder: Int64
    {
        switch package.type
        {
        case .formula:
            return appState.formulaFolderSize
        case .cask:
            return appState.caskFolderSize
        }
    }
    
    var percentageOfTotalSizeThePackageTakesUp: Double
    {
        return (Double(packageSizeInBytes) / Double(sizeOfTheCorrespondingFolder)) * 100
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            Chart
            {
                BarMark(x: .value(package.name(withPrecision: .inlineFormatted), packageSizeInBytes))
                    .foregroundStyle(package.type == .formula ? .purple : .orange)
                
                BarMark(x: .value("package-details.size-in-graph.rest-of-folder.label", sizeOfTheCorrespondingFolder - packageSizeInBytes))
                    .foregroundStyle(.gray)
            }
            .chartXAxis(.hidden)
            .chartXScale(type: .linear)
            .chartForegroundStyleScale([
                BrewPackage.PackageType.formula: .purple,
                BrewPackage.PackageType.cask: .orange
            ])
            .cornerRadius(2)
            .frame(height: 20)
            .chartLegend(.hidden)
            .accessibilityElement(children: .contain)
            .onAppear
            {
                print("Package size: \(packageSizeInBytes) / \(sizeOfTheCorrespondingFolder)")
            }
            
            HStack(alignment: .center, spacing: 10)
            {
                chartLegendItem
            }
            
            Text("package-details.size-in-graph.package-\(package.name(withPrecision: .inlineFormatted))-takes-up-\(percentageOfTotalSizeThePackageTakesUp)-percent-of-total-folder-size")
        }
    }
    
    @ViewBuilder
    var chartLegendItem: some View
    {
        HStack(alignment: .center, spacing: 4)
        {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(package.type.color)

            
            Text(package.name(withPrecision: .inlineFormatted))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
