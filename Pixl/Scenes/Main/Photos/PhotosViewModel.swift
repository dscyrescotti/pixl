//
//  PhotosViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator
import UIKit
import Action

class PhotosViewModel {
    
    private var isLoading = false
    private let bag = DisposeBag()
    private var isEnd = false
    
    lazy var photos = BehaviorRelay<[Photo]>(value: [])
    private lazy var page = BehaviorRelay<Int>(value: 1)
    
    lazy var didScrollToBottom = PublishRelay<Void>()
    lazy var willDisplayCell = PublishRelay<(cell: UICollectionViewCell, at: IndexPath)>()
    lazy var selectedItem = PublishRelay<IndexPath>()
    
    private let router: UnownedRouter<HomeRoute>
    
    init(_ router: UnownedRouter<HomeRoute>) {
        self.router = router
        bind()
    }
    
    func bind() {
        bindPhotos()
        bindPage()
        bindSelectedItem()
        bindWillDisplayCell()
        bindDidScrollToBottom()
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
            .filter { !self.isEnd }
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
                print("[Fetch]: Start fetching page \($0)")
            })
            .flatMap { [unowned self] page -> Observable<[Photo]> in
                self.isLoading = true
                return APIService.shared.getPhotos(page: page)
            }
            .asDriver(onErrorRecover: { [unowned self] _ in
                self.isLoading = false
                return Driver.just([])
            })
            .filter { [unowned self] photos in
                if photos.isEmpty {
                    isEnd = true
                }
                return !photos.isEmpty
            }
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
}
