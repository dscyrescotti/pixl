//
//  UserPhotosViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 03/05/2021.
//

import UIKit
import RxSwift
import SegementSlide

class UserPhotosViewController: UIViewController, SegementSlideContentScrollViewDelegate, Bindable, ParentAccessible {
    var parentView: UIView!
    
    var viewModel: UserPhotosViewModel!
    private var bag = DisposeBag()
    
    private var collectionView: UICollectionView
    private var layout: WaterfallLayout
    
    init() {
        self.layout = WaterfallLayout()
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc var scrollView: UIScrollView {
        return collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        setUpCollectionView()
    }
    
    func bindViewModel() {
        viewModel.photos
            .bind(to: collectionView.rx.items(cellIdentifier: PhotoCell.identifier, cellType: PhotoCell.self)) { item, photo, cell in
                cell.placeholder(with: photo)
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

extension UserPhotosViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
    }
    
    func setUpCollectionView() {
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = parentView.orientation(portrait: 2, landscape: 3)
        
        collectionView.contentInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
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
        layout.numberOfColumns = parentView.orientation(portrait: 2, landscape: 3)
        layout.invalidateLayout()
    }
}

extension UserPhotosViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        viewModel.photos.value[indexPath.item].size(for: withWidth).height
    }
}
