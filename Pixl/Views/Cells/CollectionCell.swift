//
//  CollectionCell.swift
//  Pixl
//
//  Created by Dscyre Scotti on 09/06/2021.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

class CollectionCell: UICollectionViewCell {
    static let identifier = "CollectionCell"
    
    private var placeholder: UIImage?
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let gradientView = UIView()
    
    let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.textColor = .white
        $0.numberOfLines = 2
    }
    
    let photoCountLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .white
        $0.numberOfLines = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]

        gradientView.layer.insertSublayer(gradient, at: 0)
        
        addSubview(imageView)
        addSubview(gradientView)
        addSubview(titleLabel)
        addSubview(photoCountLabel)
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self)
        }
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(10)
            make.bottom.equalTo(photoCountLabel.snp.top).offset(-4)
        }
        
        photoCountLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self).inset(10)
        }
    }
    
    func placeholder(with collection: PhotoCollection) {
        if let photo = collection.coverPhoto {
            placeholder = UIImage(blurHash: photo.blurHash, size: CGSize(width: 20, height: 20))
            imageView.image = placeholder
            imageView.backgroundColor = UIColor(photo.color)
        }
        titleLabel.text = collection.title
        photoCountLabel.text = "\(collection.totalPhotos) Photo\(collection.totalPhotos == 0 ? "" : "s")"
    }
    
    func configure(with collection: PhotoCollection) {
        if let photo = collection.coverPhoto {
            self.imageView.kf.setImage(with: URL(string: photo.urls.thumb), placeholder: self.placeholder, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2))])
        }
    }
    
    override func prepareForReuse() {
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        placeholder = nil
        titleLabel.text = nil
        photoCountLabel.text = nil
        super.prepareForReuse()
    }
}
