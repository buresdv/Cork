//
//  String - LocalizedStringKey to String.swift
//  Cork
//
//  Created by David Bureš on 10.03.2024.
//

import Foundation
import SwiftUI

extension LocalizedStringKey
{
    var stringKey: String?
    {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }

    func stringValue(locale: Locale = .current) -> String?
    {
        guard let stringKey = stringKey else { return nil }
        guard let language = locale.language.languageCode?.identifier else { return stringKey }
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return stringKey }
        guard let bundle = Bundle(path: path) else { return stringKey }
        let localizedString = NSLocalizedString(stringKey, bundle: bundle, comment: "")
        return localizedString
    }
}
