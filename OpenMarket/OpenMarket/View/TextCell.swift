//
//  TextCell.swift
//  OpenMarket
//
//  Created by papri, Tiana on 25/05/2022.
//

import UIKit

fileprivate class RegisterTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        setUpLeftView()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.layer.borderWidth = CGFloat(1)
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    private func setUpLeftView() {
        self.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 0.0))
        self.leftViewMode = .always
    }
}

class TextCell: UICollectionViewCell {
    let nameTextField: UITextField = {
        let textField = RegisterTextField(placeholder: "상품명")
        return textField
    }()
    
    let priceTextField: UITextField = {
        let textField = RegisterTextField(placeholder: "상품가격")
        return textField
    }()
    
    let discountedPriceTextField: UITextField = {
        let textField = RegisterTextField(placeholder: "할인금액")
        return textField
    }()
    
    let stockTextField: UITextField = {
        let textField = RegisterTextField(placeholder: "재고수량")
        return textField
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["KRW","USD"])

        func attribute() {
            let selectedTextStyle = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .bold)]
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.setTitleTextAttributes(selectedTextStyle, for: .selected)
            segmentedControl.setWidth(60, forSegmentAt: 0)
            segmentedControl.setWidth(60, forSegmentAt: 1)
            segmentedControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        
        attribute()
        
        return segmentedControl
    }()
    
    //MARK: - stackView
    let baseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        let inset = CGFloat(5)
        NSLayoutConstraint.activate([
            baseStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            baseStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            baseStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            baseStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
        ])
        
        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: 30),
            priceTextField.heightAnchor.constraint(equalToConstant: 30),
            stockTextField.heightAnchor.constraint(equalToConstant: 30),
            discountedPriceTextField.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    private func addSubViews() {
        priceStackView.addArrangedSubviews(priceTextField, segmentedControl)
        baseStackView.addArrangedSubviews(nameTextField, priceStackView, discountedPriceTextField, stockTextField, descriptionTextView)
        contentView.addSubview(baseStackView)
    }
}
