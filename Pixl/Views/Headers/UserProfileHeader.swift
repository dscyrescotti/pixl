//
//  UserProfileHeader.swift
//  Pixl
//
//  Created by Dscyre Scotti on 01/06/2021.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class UserProfileHeader: UIView {
    
    lazy var user = PublishRelay<User>()
    private let bag = DisposeBag()
    
    private var profileImage = UIImageView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private var nameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.numberOfLines = 1
        $0.sizeToFit()
    }
    
    private var usernameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.numberOfLines = 1
        $0.sizeToFit()
    }
    
    private var followerLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.numberOfLines = 1
        $0.sizeToFit()
        $0.textAlignment = .center
    }
    
    private var followButton = UIButton(type: .system).then {
        $0.setTitle("Follow", for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.contentEdgeInsets = .init(v: 7.5, h: 45)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bind()
        
        view.addSubview(profileImage)
        view.addSubview(followButton)
        view.addSubview(followerLabel)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
    }
    
    override func layoutSubviews() {
        profileImage.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.top.equalTo(view).inset(10)
        }
        
        followerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(profileImage.snp.centerY).offset(-4)
            make.centerX.equalTo(followButton).inset(10)
        }
        
        followButton.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.centerY).offset(4)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        user.subscribe(onNext: { [unowned self] user in
            profile(with: user.profileImage.large)
            nameLabel.text = user.name
            usernameLabel.text = "@\(user.username)"
//            biographyLabel.text = user.bio
            if let followersCount = user.followersCount {
                followerLabel.text = "\(followersCount.shorted()) Follower\(followersCount == 0 ? "" : "s")"
            }
        })
        .disposed(by: bag)
        
    }
    
    private func profile(with url: String) {
        profileImage.kf.setImage(with: URL(string: url), placeholder: nil, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2))])
    }
}
