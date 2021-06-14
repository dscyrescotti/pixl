//
//  TopicViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 14/06/2021.
//

import UIKit

class TopicViewController: UIViewController, Bindable {
    var viewModel: TopicViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    func bindViewModel() {
        
    }
}

extension TopicViewController {
    func setUp() {
        view.backgroundColor = .systemTeal
    }
}
