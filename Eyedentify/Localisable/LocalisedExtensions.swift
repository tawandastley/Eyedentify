//
//  LocalisedExtensions.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/08/17.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
