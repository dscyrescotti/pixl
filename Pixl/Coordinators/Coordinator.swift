//
//  Coordinator.swift
//  Pixl
//
//  Created by Dscyre Scotti on 20/04/2021.
//

import Foundation

protocol Coordinator {
    var childCoordinator: [Coordinator] { get set }
    func start()
}
