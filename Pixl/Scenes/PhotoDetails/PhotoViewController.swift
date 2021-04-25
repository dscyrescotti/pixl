//
//  PhotoViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 25/04/2021.
//

import UIKit
import SnapKit
import RxSwift
import Then

class PhotoViewController: UIViewController, Bindable {
    
    var viewModel: PhotoViewModel!
    private var firstLoad = true
    
    private let bag = DisposeBag()
    
    private let scrollView = UIScrollView()
    
    private let headerView = UIView().then {
        $0.backgroundColor = .systemBackground
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .systemTeal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    func bindViewModel() {
        scrollView.rx.didScroll
            .subscribe { [unowned self] _ in
                let contentOffsetY = scrollView.contentOffset.y
                let maxY = view.safeAreaInsets.top
                let height = 250 - contentOffsetY
                let headerHeight = max(height, maxY)
                
                headerView.frame = .init(x: 0, y: contentOffsetY, width: view.frame.width, height: headerHeight)
                
                let point = maxY * 1.2
                if headerHeight <= point {
                    imageView.alpha = (headerHeight - maxY) / 20
                } else {
                    imageView.alpha = 1
                }
                
            }
            .disposed(by: bag)
        
        let photo = viewModel.photo.share()
        
        photo.map { UIImage(blurHash: $0.blurHash, size: CGSize(width: 20, height: 20)) }
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
        
        photo.map { ($0.urls.regular, $0.blurHash) }
            .subscribe(onNext: { [unowned self] in
                let placeholder = UIImage(blurHash: $0.1, size: CGSize(width: 20, height: 20))
                imageView.kf.setImage(with: URL(string: $0.0), placeholder: placeholder, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2))])
            })
            .disposed(by: bag)
        photo.compactMap { UIColor(hex: $0.color) }
            .asDriver(onErrorJustReturn: .systemBackground)
            .drive(headerView.rx.backgroundColor)
            .disposed(by: bag)
            
    }
    
}

extension PhotoViewController {
    func setUp() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(headerView)
        headerView.addSubview(imageView)
        
//        headerView.frame = .init(x: 0, y: -view.safeAreaInsets.top, width: view.frame.width, height: 250 + view.safeAreaInsets.top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(250 + 10)
            make.bottom.equalTo(scrollView).offset(-10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(1500)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(headerView)
        }
        
//        if firstLoad {
//            headerView.frame = .init(x: 0, y: -view.safeAreaInsets.top, width: view.frame.width, height: 250 + view.safeAreaInsets.top)
//            firstLoad = false
//        }
    }
}
