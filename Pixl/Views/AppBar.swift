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
        $0.backgroundColor = .systemBackground
    }
    
    let seperator = UIView().then {
        $0.backgroundColor = .systemGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bar)
        addSubview(seperator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bar.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        seperator.snp.makeConstraints {
            $0.bottom.leading.trailing.equalTo(self)
            $0.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
