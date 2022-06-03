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
        guard isProductDetailEmpty() == false else { return }
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
    
    private func isImagesFull() -> Bool {
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
    
    func isValidPatchData(completionHandler: @escaping (Result<Data, NetworkError>) -> Void) -> Bool {
        if isProductDetailEmpty() == false {
            patchData(completionHandler: completionHandler)
            return true
        }
        return false
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
    
    private func setProductInputName(with value: String?) {
        productInput.setName(with: value)
    }
    
    private func setProductInputPrice(with value: String?) {
        productInput.setPrice(with: value)
    }
    
    private func setProductInputDiscountedPrice(with value: String?) {
        productInput.setDiscountedPrice(with: value)
    }
    
    private func setProductInputStock(with value: String?) {
        productInput.setStock(with: value)
    }
    
    func setDescriptions(with value: String?) {
        productInput.setDescriptions(with: value)
    }
    
    func getProductDetail() -> ProductDetail? {
        return product
    }
    
    func isNotEdited() -> Bool {
        return isProductDetailEmpty() == false && isProductInputEmpty()
    }
    
    func setProductInput(textField: UITextField) {
        switch textField.placeholder {
        case "상품명":
            setProductInputName(with: textField.text)
        case "상품가격":
            setProductInputPrice(with: textField.text)
        case "할인금액":
            setProductInputDiscountedPrice(with: textField.text)
        case "재고수량":
            setProductInputStock(with: textField.text)
        default:
            break
        }
    }
    
    func getImageItemCount() -> Int {
        if isProductDetailEmpty(), isImagesFull() {
            return 5
        }
        let imageCount = getImagesCount()
        let itemCount = isProductDetailEmpty() ? imageCount + 1 : imageCount
        return itemCount
    }
}
