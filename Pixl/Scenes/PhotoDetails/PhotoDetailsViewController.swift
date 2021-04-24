//
//  PhotoDetailsViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 23/04/2021.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }

}

extension PhotoDetailsViewController {
    func setUp() {
        title = "Details"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemPink
    }
}
