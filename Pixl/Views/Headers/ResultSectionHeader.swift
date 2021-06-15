//
//  ResultSectionHeader.swift
//  Pixl
//
//  Created by Dscyre Scotti on 15/06/2021.
//

import UIKit

class ResultSectionHeader: UICollectionReusableView {
    
    static let identifier = "ResultSectionHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        view.backgroundColor = .systemGreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
