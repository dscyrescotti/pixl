//
//  PhotoCell.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import SnapKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    static let identifier = "PhotoCell"
    
    private var placeholder: UIImage?
//    private var shouldAnimate: Bool = true
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self)
        }
    }
    
    func placeholder(with photo: Photo) {
        placeholder = UIImage(blurHash: photo.blurHash, size: CGSize(width: 20, height: 20))
        imageView.image = placeholder
    }
    
    func configure(with photo: Photo) {
        self.imageView.kf.setImage(with: URL(string: photo.urls.small), placeholder: self.placeholder, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2))])
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        placeholder = nil
        super.prepareForReuse()
    }
}
