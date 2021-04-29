//
//  UserProfileRow.swift
//  Pixl
//
//  Created by Dscyre Scotti on 27/04/2021.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift
import RxGesture

class UserProfileRow: UIView {
    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 30
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .secondarySystemBackground
        $0.isHidden = true
    }
    
    private let displayNameLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .preferredFont(forTextStyle: .title2)
        $0.sizeToFit()
    }
    
    private let userNameLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.sizeToFit()
    }
    
    private let vstack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }
    
    lazy var user = PublishRelay<User>()
    lazy var tapAction = PublishRelay<Void>()
    
    private let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(vstack)
        
        vstack.addArrangedSubview(displayNameLabel)
        vstack.addArrangedSubview(userNameLabel)
        bind()
    }
    
    private func bind() {
        user
            .map { $0.profileImage.medium }
            .subscribe(onNext: { [unowned self] in
                imageView.kf.setImage(with: URL(string: $0), placeholder: imageView.image, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2)), .keepCurrentImageWhileLoading])
                imageView.isHidden = false
            })
            .disposed(by: bag)
        user
            .map { "@\($0.username)" }
            .bind(to: userNameLabel.rx.text)
            .disposed(by: bag)
        user
            .map { $0.name }
            .bind(to: displayNameLabel.rx.text)
            .disposed(by: bag)
        
        imageView.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: tapAction)
            .disposed(by: bag)
        
        displayNameLabel.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: tapAction)
            .disposed(by: bag)
        
        userNameLabel.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: tapAction)
            .disposed(by: bag)
            
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.leading.equalTo(self).offset(10)
            make.top.bottom.equalTo(self).inset(10)
        }
        
        vstack.snp.makeConstraints { make in
            make.top.bottom.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalTo(self).offset(-10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
