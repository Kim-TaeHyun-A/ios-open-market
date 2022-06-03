//
//  UpdateImageViewModel.swift
//  OpenMarket
//
//  Created by papri, Tiana on 03/06/2022.
//

import UIKit

protocol CollectionViewSettingProtocol: AnyObject {
    func loadData() -> Void
}

class UpdateImageViewModel {
    private weak var delegate: CollectionViewSettingProtocol?
    private var images: [UIImage] = [] {
        didSet {
            delegate?.loadData()
        }
    }
    
    func setDelegate(with viewController: CollectionViewSettingProtocol) {
        delegate = viewController
    }
    
    func append(image: UIImage) {
        images.append(image)
    }
    
    func isImagesEmpty() -> Bool {
        return images.isEmpty
    }
    
    func isImagesFull() -> Bool {
        return images.count == 5
    }
    
    func getImages() -> [UIImage] {
        return images
    }
    
    func getImagesCount() -> Int {
        return images.count
    }
    
    func getImage(from index: Int) -> UIImage? {
        return images[safe: index]
    }
}
