//
//  UIImage+.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import AVFoundation

extension UIImage {
    func height(forWidth width: CGFloat) -> CGFloat {
        let boundingRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat(MAXFLOAT)
        )
        let rect = AVMakeRect(
            aspectRatio: size,
            insideRect: boundingRect
        )
        return rect.size.height
    }
}
