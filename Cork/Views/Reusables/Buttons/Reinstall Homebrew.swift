//
//  Reinstall Homebrew.swift
//  Cork
//
//  Created by David Bureš - P on 18.01.2025.
//

import SwiftUI

struct ReinstallHomebrewButton: View
{
    var body: some View
    {     
        ButtonThatOpensWebsites(websiteURL: URL(string: "https://github.com/homebrew/install?tab=readme-ov-file#uninstall-homebrew")!, buttonText: "action.reinstall-homebrew")
    }
}
