//
//  CollectionHeader.swift
//  Pixl
//
//  Created by Dscyre Scotti on 10/06/2021.
//

import UIKit

class CollectionHeader: UICollectionReusableView {
    static let identifier = "CollectionHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(collection: PhotoCollection) {
        
    }
}
