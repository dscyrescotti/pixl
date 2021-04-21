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
    
    private var isLoading = false
    
    var photos = BehaviorRelay<[UIImage]>(value: [])
    
    private let router: UnownedRouter<HomeRoute>
    
    init(_ router: UnownedRouter<HomeRoute>) {
        self.router = router
        self.photos.accept(testPhotos)
    }
    
    var testPhotos = [1,2,3,1,2,3,1,2,3].shuffled().compactMap {
        UIImage(named: String($0))
    }
    
    func nextPhotos() {
        if !isLoading {
            isLoading = true
            photos.accept(photos.value + testPhotos)
            isLoading = false
        }
    }
    
}
