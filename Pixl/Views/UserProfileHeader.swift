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
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
    }
    
    private var nameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .title2)
        $0.numberOfLines = 1
        $0.sizeToFit()
    }
    
    private var usernameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.numberOfLines = 1
        $0.sizeToFit()
    }
    
    private var statisticsRow = StatisticsRow().then {
        $0.withBorder = false
        $0.captionFont = .systemFont(ofSize: 14.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bind()
        
        view.addSubview(profileImage)
        view.addSubview(statisticsRow)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
    }
    
    override func layoutSubviews() {
        profileImage.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.top.equalTo(view).inset(10)
        }

        statisticsRow.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(profileImage.snp.bottomMargin).offset(10)
        }

        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(profileImage.snp.centerY).offset(-4)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.centerY).offset(4)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
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
            statisticsRow.observer.accept(user.statsitics)
        })
        .disposed(by: bag)
        
    }
    
    private func profile(with url: String) {
        profileImage.kf.setImage(with: URL(string: url), placeholder: nil, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2))])
    }
}
