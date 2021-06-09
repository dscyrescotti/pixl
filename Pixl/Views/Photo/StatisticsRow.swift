//
//  StatisticsRow.swift
//  Pixl
//
//  Created by Dscyre Scotti on 27/04/2021.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class StatisticsRow: UIView {
    
    lazy var observer = PublishRelay<[(String, String)]>()
    private let bag = DisposeBag()
    
    private let hstack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillEqually
        $0.isHidden = true
    }
    
    private var boxes: [StatisticsBox] = [.init(), .init(), .init()]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        boxes.forEach { box in
            hstack.addArrangedSubview(box)
        }
        addSubview(hstack)
        bind()
    }
    
    func bind() {
        observer
            .subscribe(onNext: { [unowned self] value in
                boxes.enumerated().forEach { index, box in
                    let data = value[index]
                    box.configure(title: data.0, value: data.1)
                }
                self.hstack.isHidden = false
            })
            .disposed(by: bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        hstack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(5)
            make.top.bottom.equalTo(self)
        }
        
        boxes.forEach { box in
            box.snp.makeConstraints { make in
                make.top.bottom.equalTo(hstack).inset(10)
            }
        }
    }
    
}

class StatisticsBox: UIView {
    private let digitLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textAlignment = .center
    }
    
    private let textLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textAlignment = .center
    }
    
    private let vstack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fillEqually
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        vstack.addArrangedSubview(digitLabel)
        vstack.addArrangedSubview(textLabel)
        
        addSubview(vstack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        vstack.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(5)
        }
    }
    
    func configure(title: String, value: String) {
        textLabel.text = title
        digitLabel.text = value
        vstack.layer.cornerRadius = 10
        vstack.layer.borderWidth = 0.5
        vstack.layer.borderColor = UIColor.label.cgColor
    }
}

