//
//  TagRow.swift
//  Pixl
//
//  Created by Dscyre Scotti on 28/04/2021.
//

import UIKit
import TagListView

class TagRow: ReusableRow, TagListViewDelegate {
    
    private let tagListView = TagListView().then {
        $0.enableRemoveButton = false
        $0.tagBackgroundColor = .systemBackground
        $0.textFont = .preferredFont(forTextStyle: .subheadline)
        $0.cornerRadius = 3
        $0.borderWidth = 0.4
        $0.textColor = .label
        $0.paddingX = 8
        $0.paddingY = 8
        $0.marginY = 8
        $0.marginX = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tagListView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !subviews.isEmpty {
            tagListView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.leading.trailing.equalTo(titleLabel)
                make.bottom.equalTo(self).offset(-10)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with titles: [String], for title: String) {
        titleLabel.text = title
        tagListView.addTags(titles)
        if subviews.isEmpty {
            addSubview(titleLabel)
            addSubview(tagListView)
        }
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
    }
}


