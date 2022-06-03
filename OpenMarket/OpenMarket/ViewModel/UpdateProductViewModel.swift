//
//  UpdateProductViewModel.swift
//  OpenMarket
//
//  Created by papri, Tiana on 03/06/2022.
//

import UIKit

class UpdateProductViewModel {
    private var productInput = ProductInput()
    private var product: ProductDetail?
    private var images = UpdateImageViewModel()
    
    func setUpProductDetail(with product: ProductDetail) {
        self.product = product
    }
    
    func isProductDetailEmpty() -> Bool {
        return product == nil
    }
    
    func setImagesDelegate(with viewController: CollectionViewSettingProtocol) {
        images.setDelegate(with: viewController)
    }
    
    func fetchProductDetailImage() {
        product?.images.forEach { image in
            DataProvider.shared.fetchImage(urlString: image.url) { [weak self] image in
                self?.images.append(image: image)
            }
        }
    }
    
    func appendImage(with image: UIImage) {
        images.append(image: image)
    }
    
    func isImagesEmpty() -> Bool {
        return images.isImagesEmpty()
    }
    
    func isImagesFull() -> Bool {
        return images.isImagesFull()
    }
    
    func getImagesCount() -> Int {
        return images.getImagesCount()
    }
    
    func getImage(from index: Int) -> UIImage? {
        return images.getImage(from: index)
    }
    
    func isProductInputNameValid() -> Bool {
        return productInput.isValidName(product: product)
    }
    
    func isProductDescriptionValid() -> Bool {
        return productInput.isValidDescription(product: product)
    }
    
    func convertDescription() {
        productInput.convertDescription()
    }
    
    func isProductInputEmpty() -> Bool {
        return productInput.isEmpty
    }
    
    func patchData(completionHandler: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let product = product else {
            return
        }

        DataSender.shared.patchProductData(prductIdentifier: product.identifier, productInput: productInput.getProductInput(), completionHandler: completionHandler)
    }
    
    func postData(completionHandler: @escaping (Result<Data, NetworkError>) -> Void) {
        let images = images.getImages()
        
        DataSender.shared.postProductData(images: images, productInput: productInput.getProductInput(), completionHandler: completionHandler)
    }
    
    func setProductInputDefaultCurrency() {
        productInput.setDefaultCurrency()
    }
    
    func setProductInputCurrency(with value: String?) {
        productInput.setCurrency(with: value)
    }
    
    func setProductInputName(with value: String?) {
        productInput.setName(with: value)
    }
    
    func setProductInputPrice(with value: String?) {
        productInput.setPrice(with: value)
    }
    
    func setProductInputDiscountedPrice(with value: String?) {
        productInput.setDiscountedPrice(with: value)
    }
    
    func setProductInputStock(with value: String?) {
        productInput.setStock(with: value)
    }
    
    func setDescriptions(with value: String?) {
        productInput.setDescriptions(with: value)
    }
    
    func getProductDetail() -> ProductDetail? {
        return product
    }
}
