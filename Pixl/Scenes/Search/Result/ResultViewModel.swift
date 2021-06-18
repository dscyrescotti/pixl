//
//  ResultViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 18/06/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator
import UIKit
import Action

class ResultViewModel {
    
    private var isLoading = false
    private let bag = DisposeBag()
    
    lazy var results = BehaviorRelay<[SearchResult]>(value: [])
    
    private lazy var page = BehaviorRelay<Int>(value: 1)
    private lazy var isFetching = BehaviorRelay<Bool>(value: false)
    
    lazy var didScrollToBottom = PublishRelay<Void>()
    lazy var willDisplayCell = PublishRelay<(cell: UICollectionViewCell, at: IndexPath)>()
    lazy var selectedItem = PublishRelay<IndexPath>()
    
    private let router: UnownedRouter<SearchRoute>
    private let searchType: SearchType
    private let query: String
    
    init(_ router: UnownedRouter<SearchRoute>, searchType: SearchType, query: String) {
        self.router = router
        self.searchType = searchType
        self.query = query
        bind()
    }
    
    func bind() {
        bindResults()
        bindPage()
        bindSelectedItem()
        bindWillDisplayCell()
        bindDidScrollToBottom()
    }
    
    private func bindSelectedItem() {
        selectedItem
            .flatMap { [unowned self] indexPath -> Observable<Void> in
                let result = self.results.value[indexPath.item]
                switch result {
                case .photo(let photo):
                    return self.router.rx.trigger(.photo(.details(photo: photo)))
                case .collection(let collection):
                    return self.router.rx.trigger(.collection(.details(collection: collection)))
                }
            }
            .subscribe()
            .disposed(by: bag)
    }
    
    private func bindResults() {
        results
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
            .flatMap { [unowned self] page -> Observable<[SearchResult]> in
                self.isLoading = true
                switch searchType {
                case .photo:
                    return APIService.shared.searchPhotos(query: query, page: page, perPage: 50)
                        .map { $0.searchModel.results }
                case .collection:
                    return APIService.shared.searchCollections(query: query, page: page, perPage: 50)
                        .map { $0.searchModel.results }
                }
            }
            .asDriver(onErrorRecover: { [unowned self] _ in
                self.isLoading = false
                return Driver.just([])
            })
            .filter { !$0.isEmpty }
            .map { [unowned self] new in
                self.results.value + new
            }
            .drive(results)
            .disposed(by: bag)
    }
    
    private func bindWillDisplayCell() {
        willDisplayCell
            .subscribe(onNext: { [unowned self] cell, indexPath in
                let result = results.value[indexPath.item]
                switch result {
                case let .photo(photo):
                    (cell as? PhotoCell)?.configure(with: photo)
                case let .collection(collection):
                    (cell as? CollectionCell)?.configure(with: collection)
                }
            })
            .disposed(by: bag)
    }
}

