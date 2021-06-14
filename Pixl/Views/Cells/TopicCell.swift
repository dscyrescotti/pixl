//
//  TopicCell.swift
//  Pixl
//
//  Created by Dscyre Scotti on 14/06/2021.
//

import UIKit

class TopicCell: UICollectionViewCell {
    static let identifier = "TopicCell"
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private var placeholder: UIImage?
    
    let gradientView = UIView()
    let gradient = CAGradientLayer()
    
    let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .white
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientView.layer.insertSublayer(gradient, at: 0)
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        addSubview(imageView)
        addSubview(gradientView)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        gradient.frame = view.bounds
        
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(self).inset(10)
        }
    }
    
    func placeholder(with topic: Topic) {
        placeholder = UIImage(blurHash: topic.coverPhoto.blurHash, size: CGSize(width: 20, height: 20))
        imageView.image = placeholder
        imageView.backgroundColor = UIColor(topic.coverPhoto.color)
    }
    
    func configure(with topic: Topic) {
        self.imageView.kf.setImage(with: URL(string: topic.coverPhoto.urls.thumb), placeholder: self.placeholder, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2))])
        titleLabel.text = topic.title
    }
    
    override func prepareForReuse() {
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        placeholder = nil
        titleLabel.text = nil
        super.prepareForReuse()
    }
}
