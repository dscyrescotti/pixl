//
//  PhotosViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import RxSwift

class PhotosViewController: UIViewController, Bindable {
    
    var viewModel: PhotosViewModel!
    private var bag = DisposeBag()
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        setUpCollectionView()
    }
    
    func bindViewModel() {
        viewModel.photos
            .bind(to: collectionView.rx.items(cellIdentifier: PhotoCell.identifier)) { _, image, cell in
                guard let cell = cell as? PhotoCell else { return }
                cell.configure(with: image)
            }
            .disposed(by: bag)
    }
}

extension PhotosViewController {
    func setUp() {
        view.backgroundColor = .systemPink
    }
    
    func setUpCollectionView() {
        let layout = WaterfallLayout()
        layout.cellPadding = 5
        layout.delegate = self
        layout.numberOfColumns = Orientation.if(portrait: 2, landscape: 3)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? WaterfallLayout else { return }
        layout.numberOfColumns = Orientation.if(portrait: 2, landscape: 3)
        layout.invalidateLayout()
    }
}

extension PhotosViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        viewModel.photos.value[indexPath.item].height(forWidth: withWidth)
    }
}
