//
//  UserPhotosViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 03/05/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator
import UIKit
import Action

class UserPhotosViewModel {
    
    private var isLoading = false
    private let bag = DisposeBag()
    private let username: String?
    private let type: PhotoType
    
    private let router: UnownedRouter<UserRoute>
    
    lazy var photos = BehaviorRelay<[Photo]>(value: [])
    private lazy var page = BehaviorRelay<Int>(value: 1)
    private lazy var isFetching = BehaviorRelay<Bool>(value: false)
    
    lazy var didScrollToBottom = PublishRelay<Void>()
    lazy var willDisplayCell = PublishRelay<(cell: UICollectionViewCell, at: IndexPath)>()
    lazy var selectedItem = PublishRelay<IndexPath>()
    lazy var labelHidden = PublishRelay<Bool>()
    
    init(username: String?, type: PhotoType = .photos, router: UnownedRouter<UserRoute>) {
        self.username = username
        self.type = type
        self.router = router
        bind()
    }
    
    func bind() {
        bindPhotos()
        bindPage()
        bindSelectedItem()
        bindWillDisplayCell()
        bindDidScrollToBottom()
        bindHiddenLabel()
    }
    
    func bindHiddenLabel() {
        labelHidden
            .subscribe(onNext: { _ in
                self.isLoading = false
            })
            .disposed(by: bag)
    }
    
    private func bindSelectedItem() {
        selectedItem
            .flatMap { [unowned self] indexPath -> Observable<Void> in
                let photo = self.photos.value[indexPath.item]
                return self.router.rx.trigger(.photo(.details(photo: photo)))
            }
            .subscribe()
            .disposed(by: bag)
    }
    
    private func bindPhotos() {
        photos
            .subscribe(onNext: { _ in
                self.isLoading = false
            })
            .disposed(by: bag)
    }
    
    private func bindDidScrollToBottom() {
        didScrollToBottom
            .filter { !self.isLoading }
            .flatMap { [unowned self] _ -> Observable<Int> in
                let next = self.page.value + 1
                return Observable.just(next)
            }
            .bind(to: page)
            .disposed(by: bag)
    }
    
    private func bindPage() {
        page
            .do(onNext: {
                print("[Fetch]: Start fetching page \($0) of user")
            })
            .flatMap { [unowned self] page -> Observable<[Photo]> in
                self.isLoading = true
                if let username = username {
                    return APIService.shared.getUserPhotos(username: username, type: type.rawValue, page: page)
                } else {
                    return Observable.empty()
                }
                
            }
            .asDriver(onErrorRecover: { [unowned self] _ in
                self.isLoading = false
                return Driver.just([])
            })
            .do(onNext: { [unowned self] in
                if $0.isEmpty && photos.value.isEmpty {
                    labelHidden.accept(false)
                }
            })
            .filter { !$0.isEmpty }
            .map { [unowned self] new in
                self.photos.value + new
            }
            .drive(photos)
            .disposed(by: bag)
    }
    
    private func bindWillDisplayCell() {
        willDisplayCell
            .subscribe(onNext: { [unowned self] cell, indexPath in
                guard let photoCell = cell as? PhotoCell else { return }
                photoCell.configure(with: photos.value[indexPath.item])
            })
            .disposed(by: bag)
    }
    
    enum PhotoType: String {
        case photos, likes
    }
}
