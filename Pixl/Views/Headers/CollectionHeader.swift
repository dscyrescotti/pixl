//
//  CollectionHeader.swift
//  Pixl
//
//  Created by Dscyre Scotti on 10/06/2021.
//

import UIKit
import RxCocoa
import RxSwift

class CollectionHeader: UICollectionReusableView {
    static let identifier = "CollectionHeader"
    
    var tapTrigger: (() -> Void)? = nil
    
    lazy var tapAction = PublishRelay<Void>()
    private let bag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .title1)
        $0.numberOfLines = 1
        $0.sizeToFit()
    }
    
    private let createdByLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.numberOfLines = 1
        $0.text = "Created by"
        $0.sizeToFit()
    }
    
    private let profileRow = UserProfileRow().then {
        $0.style = .small
    }
    
    private let totalPhotosLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.numberOfLines = 1
        $0.sizeToFit()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(createdByLabel)
        addSubview(profileRow)
        addSubview(totalPhotosLabel)
        
        bind()
    }
    
    private func bind() {
        profileRow.tapAction
            .bind(to: tapAction)
            .disposed(by: bag)
        tapAction
            .subscribe(onNext: { [unowned self] in
                tapTrigger?()
            })
            .disposed(by: bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self).inset(5)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
        
        createdByLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
        
        profileRow.snp.makeConstraints { make in
            make.top.equalTo(createdByLabel.snp.bottom)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
        
        totalPhotosLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-5)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
    }
    
    func configure(collection: PhotoCollection) {
        titleLabel.text = collection.title
        totalPhotosLabel.text = "\(collection.totalPhotos) Photo\(collection.totalPhotos > 1 ? "s" : "")"
        profileRow.user.accept(collection.user)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        totalPhotosLabel.text = nil
    }
}
