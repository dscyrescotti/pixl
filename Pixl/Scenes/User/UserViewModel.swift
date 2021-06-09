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
    let user: BehaviorRelay<User>
    
    let router: UnownedRouter<UserRoute>
    
    init(user: User, router: UnownedRouter<UserRoute>) {
        self.user = BehaviorRelay(value: user)
        self.router = router
        bindUser(username: user.username)
    }
    
    func bindUser(username: String) {
        APIService.shared.getUser(username: username)
            .bind(to: user)
            .disposed(by: bag)
    }
    
}
