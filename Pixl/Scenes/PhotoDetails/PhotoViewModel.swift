//
//  PhotoViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 25/04/2021.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoViewModel {
    private let _photo: Photo
    private let bag = DisposeBag()
    
    lazy var photo = PublishRelay<Photo>()
    
    init(photo: Photo) {
        self._photo = photo
        bind()
    }
    
    private func bind() {
        photo.accept(_photo)
        bindPhoto()
    }
    
    private func bindPhoto() {
        APIService.shared.getPhoto(id: _photo.id)
            .bind(to: photo)
            .disposed(by: bag)
    }
}
