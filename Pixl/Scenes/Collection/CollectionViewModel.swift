//
//  CollectionViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 09/06/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator
import UIKit
import Action

class CollectionViewModel {
    
    private var isLoading = false
    private let bag = DisposeBag()
    
    lazy var photos = BehaviorRelay<[Photo]>(value: [])
    private lazy var page = BehaviorRelay<Int>(value: 1)
    private lazy var isFetching = BehaviorRelay<Bool>(value: false)
    var collection: BehaviorRelay<PhotoCollection>
    
    lazy var didScrollToBottom = PublishRelay<Void>()
    lazy var willDisplayCell = PublishRelay<(cell: UICollectionViewCell, at: IndexPath)>()
    lazy var willDisplaySupplementaryView = PublishRelay<(supplementaryView: UICollectionReusableView, elementKind: String, at: IndexPath)>()
    lazy var selectedItem = PublishRelay<IndexPath>()
    
    private let router: UnownedRouter<CollectionRoute>
    
    init(_ router: UnownedRouter<CollectionRoute>, collection: PhotoCollection) {
        self.router = router
        self.collection = BehaviorRelay<PhotoCollection>(value: collection)
        bindCollection(id: collection.id)
        bind()
    }
    
    func bind() {
        bindPhotos()
        bindPage()
        bindSelectedItem()
        bindWillDisplaySupplementaryView()
        bindWillDisplayCell()
        bindDidScrollToBottom()
    }
    
    private func bindCollection(id: String) {
        APIService.shared.getCollection(id: id)
            .bind(to: collection)
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
    
    private func bindWillDisplaySupplementaryView() {
        willDisplaySupplementaryView
            .subscribe(onNext: { header, _, _ in
                guard let header = header as? CollectionHeader else { return }
                header.backgroundColor = .systemPink
            })
            .disposed(by: bag)
    }
}

