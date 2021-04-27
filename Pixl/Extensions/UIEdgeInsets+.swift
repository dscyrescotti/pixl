//
//  UIEdgeInsets+.swift
//  Pixl
//
//  Created by Dscyre Scotti on 26/04/2021.
//

import UIKit

extension UIEdgeInsets {
    static func all(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    init(v: CGFloat, h: CGFloat) {
        self = UIEdgeInsets(top: v, left: h, bottom: v, right: h)
    }
}
