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
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
}
