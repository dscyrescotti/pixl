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
    
    init(user: User) {
        self.user = BehaviorRelay(value: user)
        bindUser(username: user.username)
    }
    
    func bindUser(username: String) {
        APIService.shared.getUser(username: username)
            .bind(to: user)
            .disposed(by: bag)
    }
    
}
