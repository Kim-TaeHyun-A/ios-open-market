//
//  Alert.swift
//  OpenMarket
//
//  Created by papri, Tiana on 26/05/2022.
//

import UIKit

struct Alert {
    private enum Title {
        case image
        case name
        case description
        case noChange
        case failedNetwork
        
        var string: String {
            switch self {
            case .image:
                return "이미지를 1개 이상 선택하세요."
            case .name:
                return "3자 이상으로 이름을 입력하세요."
            case .description:
                return "10자 이상 descripion을 입력하세요."
            case .noChange:
                return "수정 사항이 없으면\ncancel을 눌러주세요"
            case .failedNetwork:
                return "실패했습니다"
            }
        }
    }
    
    func setUpTitle(updateProductViewModel: UpdateProductViewModel? = nil) -> String? {
        guard let updateProductViewModel = updateProductViewModel else {
            return Title.failedNetwork.string
        }

        if updateProductViewModel.isImagesEmpty() {
            return Title.image.string
        } else if updateProductViewModel.isProductInputNameValid() == false {
            return Title.name.string
        } else if updateProductViewModel.isProductDescriptionValid() == false {
            return Title.description.string
        } else if updateProductViewModel.isNotEdited() {
            return Title.noChange.string
        } else {
            return nil
        }
    }
    
    func showWarning(title: String = "경고창", message: String? = nil, completionHandler: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: "ok", style: .default) { _ in
            completionHandler?()
        }
        alertController.addAction(button)
        return alertController
    }
}
