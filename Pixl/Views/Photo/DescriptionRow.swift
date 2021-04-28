//
//  DescriptionRow.swift
//  Pixl
//
//  Created by Dscyre Scotti on 27/04/2021.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class DescriptionRow: ReusableRow {
    
    private let descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !subviews.isEmpty {
            descriptionLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.leading.trailing.equalTo(titleLabel)
                make.bottom.equalTo(self).offset(-10)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String, for title: String) {
        descriptionLabel.text = text
        titleLabel.text = title
        if subviews.isEmpty {
            addSubview(titleLabel)
            addSubview(descriptionLabel)
        }
    }
}
