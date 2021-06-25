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
    let isMe: Bool
    
    let router: UnownedRouter<UserRoute>
    
    init(_ type: UserType, router: UnownedRouter<UserRoute>) {
        self.router = router
        self.isMe = type.isMe
        bindUser(type: type)
    }
    
    func bindUser(type: UserType) {
        switch type {
        case .me:
            APIService.shared.getMe()
                .asDriver(onErrorRecover: { error in
                    print(error.localizedDescription)
                    return Driver.empty()
                })
                .drive(user)
                .disposed(by: bag)
        case .username(let username):
            APIService.shared.getUser(username: username)
                .asDriver(onErrorRecover: { error in
                    Driver.empty()
                })
                .drive(user)
                .disposed(by: bag)
        }
    }
    
}

enum UserType {
    case me
    case username(String)
    
    var isMe: Bool {
        switch self {
        case .me:
            return true
        case .username:
            return false
        }
    }
}
