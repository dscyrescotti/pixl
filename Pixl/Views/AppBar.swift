//
//  AppBar.swift
//  Pixl
//
//  Created by Dscyre Scotti on 26/04/2021.
//

import UIKit
import Then
import SnapKit

class AppBar: UIView {
    
    let bar = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondaryLabel
        addSubview(bar)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bar.snp.makeConstraints {
            $0.top.left.right.equalTo(self)
            $0.bottom.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
