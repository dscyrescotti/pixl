//
//  CollectionsViewModel.swift
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

class CollectionsViewModel {
    
    private var isLoading = false
    private let bag = DisposeBag()
    private var isEnd = false
    
    lazy var collections = BehaviorRelay<[PhotoCollection]>(value: [])
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
        bindCollections()
        bindPage()
        bindSelectedItem()
        bindWillDisplayCell()
        bindDidScrollToBottom()
    }
    
    private func bindSelectedItem() {
        selectedItem
            .flatMap { [unowned self] indexPath -> Observable<Void> in
                let collection = self.collections.value[indexPath.item]
                return self.router.rx.trigger(.collection(.details(collection: collection)))
            }
            .subscribe()
            .disposed(by: bag)
    }
    
    private func bindCollections() {
        collections
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
            .flatMap { [unowned self] page -> Observable<[PhotoCollection]> in
                self.isLoading = true
                return APIService.shared.getCollections(page: page)
            }
            .asDriver(onErrorRecover: { [unowned self] _ in
                self.isLoading = false
                return Driver.just([])
            })
            .filter { [unowned self] collections in
                if collections.isEmpty {
                    isEnd = true
                }
                return !collections.isEmpty
            }
            .map { [unowned self] new in
                self.collections.value + new
            }
            .drive(self.collections)
            .disposed(by: bag)
    }
    
    private func bindWillDisplayCell() {
        willDisplayCell
            .subscribe(onNext: { [unowned self] cell, indexPath in
                guard let collectionCell = cell as? CollectionCell else { return }
                collectionCell.configure(with: collections.value[indexPath.item])
            })
            .disposed(by: bag)
    }
}
