//
//  Search Result Row.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import SwiftUI

struct SearchResultRow: View
{
    @AppStorage("showDescriptionsInSearchResults") var showDescriptionsInSearchResults: Bool = false
    
    @EnvironmentObject var brewData: BrewDataStorage

    @State var packageName: String
    @State var isCask: Bool
    
    @State private var description: String = ""

    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack(alignment: .firstTextBaseline)
            {
                SanitizedPackageName(packageName: packageName, shouldShowVersion: true)
                
                if !isCask
                {
                    if brewData.installedFormulae.contains(where: { $0.name == packageName })
                    {
                        PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                    }
                }
                else
                {
                    if brewData.installedCasks.contains(where: { $0.name == packageName })
                    {
                        PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                    }
                }
            }
            
            if showDescriptionsInSearchResults
            {
                if !description.isEmpty
                {
                    Text(description)
                        .font(.caption)
                }
                else
                {
                    Text("add-package.result.loading-description")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
        }
        .onAppear
        {
            if showDescriptionsInSearchResults
            {
                Task
                {
                    print("\(packageName) came into view")
                    
                    if description.isEmpty
                    {
                        
                        print("\(packageName) does not have its description loaded")
                        
                        async let descriptionRaw = await shell(AppConstants.brewExecutablePath.absoluteString, ["info", "--json=v2", packageName]).standardOutput
                        
                        let descriptionJSON = try await parseJSON(from: descriptionRaw)
                        
                        description = getPackageDescriptionFromJSON(json: descriptionJSON, package: BrewPackage(name: packageName, isCask: isCask, installedOn: Date(), versions: [], sizeInBytes: nil))
                    }
                    else
                    {
                        print("\(packageName) already has its description loaded")
                    }
                }
            }
        }
    }
}
