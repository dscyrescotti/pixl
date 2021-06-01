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
        $0.backgroundColor = .blue
        $0.layer.cornerRadius = 40
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        view.backgroundColor = .cyan
        bind()
        
        view.addSubview(profileImage)
    }
    
    override func layoutSubviews() {
        profileImage.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.top.leading.equalTo(view).inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        user.subscribe(onNext: { user in
            print(user)
        })
        .disposed(by: bag)
    }
}
