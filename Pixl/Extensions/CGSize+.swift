//
//  CGSize+.swift
//  Pixl
//
//  Created by Dscyre Scotti on 23/04/2021.
//

import AVFoundation

extension CGSize {
    func multiple(by value: CGFloat) -> CGSize {
        .init(width: width * value, height: height * value)
    }
    
    func orientation<T>(portrait: T, landscape: T) -> T {
        width > height ? landscape : portrait
    }
}
