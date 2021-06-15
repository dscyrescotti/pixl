//
//  SearchViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 12/06/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator
import UIKit

class SearchViewModel {
    private let bag = DisposeBag()
    
    lazy var topics = BehaviorRelay<[Topic]>(value: [])
    lazy var results = BehaviorRelay<[SearchModel]>(value: [])
    
    lazy var willDisplayCell = PublishRelay<(cell: UICollectionViewCell, at: IndexPath)>()
    lazy var selectedItem = PublishRelay<IndexPath>()
    lazy var searchTrigger = PublishRelay<String>()
    
    private let router: UnownedRouter<SearchRoute>
    
    init(router: UnownedRouter<SearchRoute>) {
        self.router = router
        bind()
    }
    
    private func bind() {
        bindTopics()
        bindWillDisplayCell()
        bindSelectedItem()
        bindSearchTrigger()
    }
    
    private func bindSearchTrigger() {
        searchTrigger
            .flatMap { [unowned self] query -> Observable<[SearchModel]> in
                return search(query: query)
            }
            .bind(to: results)
            .disposed(by: bag)
    }
    
    private func search(query: String) -> Observable<[SearchModel]> {
        let searchPhotos = APIService.shared.searchPhotos(query: query, perPage: 7)
            .map { $0.searchModel }
        let searchCollections = APIService.shared.searchCollections(query: query, perPage: 7)
            .map { $0.searchModel }
        return searchPhotos.concat(searchCollections)
            .scan([], accumulator: { previous, current in
                Array(previous + [current]).suffix(2)
            })
    }
    
    private func bindTopics() {
        APIService.shared.getTopics()
            .bind(to: topics)
            .disposed(by: bag)
    }
    
    private func bindWillDisplayCell() {
        willDisplayCell
            .subscribe(onNext: { [unowned self] cell, indexPath in
                if let topicCell = cell as? TopicCell {
                    topicCell.configure(with: topics.value[indexPath.item])
                } else if cell is PhotoCell || cell is CollectionCell {
                    let result = results.value[indexPath.section].results[indexPath.item]
                    switch result {
                    case let .photo(photo):
                        (cell as? PhotoCell)?.configure(with: photo)
                    case let .collection(collection):
                        (cell as? CollectionCell)?.configure(with: collection)
                    }
                }
                
            })
            .disposed(by: bag)
    }
    
    private func bindSelectedItem() {
        selectedItem
            .flatMap { [unowned self] indexPath -> Observable<Void> in
                let topic = self.topics.value[indexPath.item]
                return self.router.rx.trigger(.topic(topic: topic))
            }
            .subscribe()
            .disposed(by: bag)
    }
}

enum SearchResult {
    case photo(Photo)
    case collection(PhotoCollection)
}
