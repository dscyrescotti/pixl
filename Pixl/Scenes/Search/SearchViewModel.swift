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
    
    lazy var willDisplayCell = PublishRelay<(cell: UICollectionViewCell, at: IndexPath)>()
    lazy var selectedItem = PublishRelay<IndexPath>()
    
    private let router: UnownedRouter<SearchRoute>
    
    init(router: UnownedRouter<SearchRoute>) {
        self.router = router
        bind()
    }
    
    private func bind() {
        bindTopics()
        bindWillDisplayCell()
        bindSelectedItem()
    }
    
    private func bindTopics() {
        APIService.shared.getTopics()
            .bind(to: topics)
            .disposed(by: bag)
    }
    
    private func bindWillDisplayCell() {
        willDisplayCell
            .subscribe(onNext: { [unowned self] cell, indexPath in
                guard let topicCell = cell as? TopicCell else { return }
                topicCell.configure(with: topics.value[indexPath.item])
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
