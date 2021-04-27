//
//  ReusableRow.swift
//  Pixl
//
//  Created by Dscyre Scotti on 27/04/2021.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ReusableRow: UIView {
    
    let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.numberOfLines = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !subviews.isEmpty {
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.leading.trailing.equalTo(self).inset(10)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
