//
//  ResultSectionHeader.swift
//  Pixl
//
//  Created by Dscyre Scotti on 15/06/2021.
//

import UIKit
import XCoordinator
import RxSwift
import RxCocoa

class ResultSectionHeader: UICollectionReusableView {
    
    static let identifier = "ResultSectionHeader"
    
    private let bag = DisposeBag()
    
    private var trigger: (() -> Void)? = nil
    
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textAlignment = .left
        $0.sizeToFit()
        $0.numberOfLines = 1
    }
    
    private let moreButton = UIButton().then {
        $0.setTitle("See More", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(moreButton)
        
        moreButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.trigger?()
            })
            .disposed(by: bag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalTo(self).inset(10)
        }
        
        moreButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(self).inset(10)
        }
    }
    
    func configure(with result: SearchModel, trigger: @escaping () -> Void) {
        titleLabel.text = "\(result.title) (\(result.total) Result\(result.total > 1 ? "s" : ""))"
        self.trigger = trigger
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        trigger = nil
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
