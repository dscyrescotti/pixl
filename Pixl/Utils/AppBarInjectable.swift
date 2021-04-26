//
//  AppBarInjectable.swift
//  Pixl
//
//  Created by Dscyre Scotti on 26/04/2021.
//

import UIKit

protocol AppBarInjectable {
    var appBar: AppBar { get set }
}

extension AppBarInjectable where Self: UIViewController {
    func registerLayout() {
        if let frame = navigationController?.navigationBar.frame {
            appBar.frame = .init(x: 0, y: 0, width: view.frame.width, height: frame.minY + frame.height)
        }
    }
    
    func addAppBar() {
        view.addSubview(appBar)
    }
}
