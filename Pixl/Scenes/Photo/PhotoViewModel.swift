//
//  PhotoViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 25/04/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator

class PhotoViewModel {
    private let bag = DisposeBag()
    
    var photo: BehaviorRelay<Photo>
    lazy var profileTrigger = PublishRelay<Void>()
    
    private let router: UnownedRouter<PhotoRoute>
    
    init(_ router: UnownedRouter<PhotoRoute>, photo: Photo) {
        self.router = router
        self.photo = BehaviorRelay<Photo>(value: photo)
        bindPhoto(id: photo.id)
    }
    
    private func bindPhoto(id: String) {
        APIService.shared.getPhoto(id: id)
            .bind(to: photo)
            .disposed(by: bag)
        
        profileTrigger
            .subscribe(onNext: { [unowned self] in
                router.trigger(.user(.details(user: photo.value.user)))
            })
            .disposed(by: bag)
    }
}
