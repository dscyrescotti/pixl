//
//  CollectionsViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import RxSwift

class CollectionsViewController: UIViewController, Bindable {
    
    var viewModel: CollectionsViewModel!
    private var bag = DisposeBag()
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        setUpCollectionView()
    }
    
    func bindViewModel() {
        viewModel.collections
            .bind(to: collectionView.rx.items(cellIdentifier: CollectionCell.identifier, cellType: CollectionCell.self)) { item, collection, cell in
                cell.placeholder(with: collection)
            }
            .disposed(by: bag)
        
        collectionView.rx.willDisplayCell
            .bind(to: viewModel.willDisplayCell)
            .disposed(by: bag)
        
        collectionView.rx.didScroll
            .filter { [unowned self] in
                let offsetY = self.collectionView.contentOffset.y
                let contentHeight = self.collectionView.contentSize.height
                return offsetY > contentHeight - self.collectionView.frame.size.height - 100
            }
            .bind(to: viewModel.didScrollToBottom)
            .disposed(by: bag)
        
        collectionView.rx.itemSelected
            .bind(to: viewModel.selectedItem)
            .disposed(by: bag)
            
    }
}

extension CollectionsViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
    }
    
    func setUpCollectionView() {
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.identifier)
        
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Warning")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? WaterfallLayout else { return }
        layout.numberOfColumns = view.orientation(portrait: 2, landscape: 3)
        layout.invalidateLayout()
    }
}

extension CollectionsViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        250
    }
}
