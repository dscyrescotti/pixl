//
//  Int+.swift
//  Pixl
//
//  Created by Dscyre Scotti on 27/04/2021.
//

import Foundation

extension Int {
    func shorted() -> String {
        if self >= 1000 && self < 10000 {
            return String(format: "%.1fK", Double(self/100)/10).replacingOccurrences(of: ".0", with: "")
        }

        if self >= 10000 && self < 1000000 {
            return "\(self/1000)k"
        }

        if self >= 1000000 && self < 10000000 {
            return String(format: "%.1fM", Double(self/100000)/10).replacingOccurrences(of: ".0", with: "")
        }

        if self >= 10000000 {
            return "\(self/1000000)M"
        }

        return String(self)
    }
}

extension Optional where Wrapped == Int {
    var string: String? {
        guard let int = self else { return nil }
        return String(int)
    }
}
