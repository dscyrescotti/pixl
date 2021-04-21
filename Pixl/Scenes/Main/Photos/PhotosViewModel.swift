//
//  PhotosViewModel.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import Foundation
import RxSwift
import RxCocoa
import XCoordinator
import UIKit
import Action

class PhotosViewModel {
    
    var photos = BehaviorRelay<[UIImage]>(value: [])
    
    private let router: UnownedRouter<HomeRoute>
    
    init(_ router: UnownedRouter<HomeRoute>) {
        self.router = router
        self.photos.accept(testPhotos)
    }
    
    var testPhotos = [1,2,3,2,3,1,2,3,1,3,1,2].compactMap {
        UIImage(named: String($0))
    }
    
    func nextPhotos() {
        photos.accept(testPhotos)
    }
    
}
