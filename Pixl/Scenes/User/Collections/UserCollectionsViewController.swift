//
//  UserCollectionsViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 11/06/2021.
//

import UIKit
import RxSwift
import SegementSlide
import Then

class UserCollectionsViewController: UIViewController, SegementSlideContentScrollViewDelegate, Bindable, ParentAccessible {
    var parentView: UIView!
    
    var viewModel: UserCollectionsViewModel!
    private var bag = DisposeBag()
    
    private var collectionView: UICollectionView
    private var layout: WaterfallLayout
    
    private let label = UILabel().then {
        $0.text = "There's no collections of user in this tab."
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
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
        setUpLabel()
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
        
        viewModel.labelHidden
            .asObservable()
            .bind(to: label.rx.isHidden)
            .disposed(by: bag)
            
    }
}

extension UserCollectionsViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
    }
    
    func setUpCollectionView() {
        layout.delegate = self
        layout.cellPadding = 5
        layout.topPadding = 5
        layout.numberOfColumns = parentView.orientation(portrait: 2, landscape: 3)
        
        collectionView.contentInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.identifier)
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
    }
    
    func setUpLabel() {
        view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.bottom.equalTo(view)
        }
        
        label.snp.makeConstraints { make in
            make.leading.trailing.centerX.centerY.equalTo(view.layoutMarginsGuide)
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

extension UserCollectionsViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        250
    }
}
