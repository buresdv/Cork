//
//  About View.swift
//  Cork
//
//  Created by David Bureš on 07.07.2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text(AppConstantsLocal.appName)
                    .font(.title)
                Text("Version 0.1")
                    .font(.subheadline)
            }

            Text("© 2022 David Bureš. All rights reserved.")

            HStack {
                Spacer()

                Button {
                    NSWorkspace.shared.open(URL(string: "https://twitter.com/davidbures")!)
                } label: {
                    Text("Twitter")
                }

                Button {
                    NSWorkspace.shared.open(URL(string: "https://github.com/buresdv/Cork")!)
                } label: {
                    Text("\(AppConstantsLocal.appName) on GitHub")
                }
            }
        }
        .padding()
        .frame(width: 300, height: 150, alignment: .topLeading)
    }
}
