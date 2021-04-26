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
        
        let photo = viewModel.photo.asObservable()
        
        photo.map { ($0.urls.regular, $0.blurHash) }
            .subscribe(onNext: { [unowned self] in
                let placeholder = UIImage(blurHash: $0.1, size: CGSize(width: 20, height: 20))
                imageView.kf.setImage(with: URL(string: $0.0), placeholder: placeholder, options: [.cacheOriginalImage, .diskCacheExpiration(.days(2)), .keepCurrentImageWhileLoading])
            })
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(toProfile))
    }
    
    @objc func toProfile() {
        viewModel.toProfile()
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
    }
}
