//
//  UserViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 02/05/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator

class UserViewModel {
    private let bag = DisposeBag()
    let user: BehaviorRelay<User?> = .init(value: nil)
    
    let router: UnownedRouter<UserRoute>
    
    init(_ type: UserType, router: UnownedRouter<UserRoute>) {
        self.router = router
        bindUser(type: type)
    }
    
    func bindUser(type: UserType) {
        switch type {
        case .me:
            APIService.shared.getMe()
                .bind(to: user)
                .disposed(by: bag)
        case .username(let username):
            APIService.shared.getUser(username: username)
                .bind(to: user)
                .disposed(by: bag)
        }
    }
    
}

enum UserType {
    case me
    case username(String)
}
