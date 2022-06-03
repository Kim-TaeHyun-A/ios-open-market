//
//  UpdateProductViewController.swift
//  OpenMarket
//
//  Created by papri, Tiana on 18/05/2022.
//

import UIKit

extension UpdateProductViewController: CollectionViewSettingProtocol {
    func loadData() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
}

class UpdateProductViewController: UIViewController {
    enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
        case image
        case text
        
        var description: String {
            switch self {
            case .image: return "Image"
            case .text: return "Text"
            }
        }
    }
    
    private let updateProductViewModel = UpdateProductViewModel()
    private lazy var imagePickerController = ImagePickerController(delgate: self)
    private var collectionView: UICollectionView?
    private var collectionViewLayout: UICollectionViewLayout?
    private var bottomConstraint: NSLayoutConstraint?
    
    lazy var completionHandler: (Result<Data, NetworkError>) -> Void = { data in
        switch data {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true)
            }
        case .failure(_):
            let alert = Alert().showWarning(title: "경고", message: "실패했습니다", completionHandler: nil)
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true)
            }
            return
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        updateProductViewModel.setImagesDelegate(with: self)
    }
    
    convenience init(product: ProductDetail) {
        self.init()
        updateProductViewModel.setUpProductDetail(with: product)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        
        updateProductViewModel.fetchProductDetailImage()
        
        collectionViewLayout = createLayout()
        
        configureHierarchy(collectionViewLayout: collectionViewLayout)
        registerCell()
        setUpCollectionView()
                
        registerNotification()
    }
}

extension UpdateProductViewController {
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardBounds = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? NSValue else { return }

        bottomConstraint?.constant = -keyboardBounds.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint?.constant = .zero
    }
    
}

extension UpdateProductViewController {
    private func setUpNavigationItem() {
        navigationItem.title = updateProductViewModel.isProductDetailEmpty() ? "상품등록": "상품수정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(touchUpDoneButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(touchUpCancelButton))
    }
    
    @objc private func touchUpDoneButton() {
        if let title = Alert().setUpTitle(updateProductViewModel: updateProductViewModel) {
            let alertController = Alert().showWarning(title: title)
            present(alertController, animated: true)
            return
        }
        
        updateProductViewModel.convertDescription()
        
        if updateProductViewModel.isValidPatchData(completionHandler: completionHandler) {
            return
        }
        
        updateProductViewModel.setProductInputDefaultCurrency()
        
        updateProductViewModel.postData(completionHandler: completionHandler)
    }
    
    @objc private func touchUpCancelButton() {
        dismiss(animated: true)
    }
}

extension UpdateProductViewController {
    private func setUpCollectionView() {
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }
    
    private func registerCell() {
        collectionView?.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView?.register(TextCell.self, forCellWithReuseIdentifier: "TextCell")
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
    }
    
    private func configureHierarchy(collectionViewLayout: UICollectionViewLayout?) {
        guard let collectionViewLayout = collectionViewLayout else { return }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        guard let collectionView = collectionView else { return }
    
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        layoutCollectionView()
    }
    
    func createLayout() -> UICollectionViewLayout {        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            
            let section: NSCollectionLayoutSection
            
            if sectionKind == .image {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalWidth(0.4))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20)
                
            } else if sectionKind == .text {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.45))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20)
            } else {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20)
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func layoutCollectionView() {
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.isScrollEnabled = false
        
        bottomConstraint = collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            collectionView?.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
        ].compactMap { $0 })
    }
}

extension UpdateProductViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return updateProductViewModel.getImageItemCount()
        } else if section == 1 {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
                return emptyCell
            }
            
            cell.set(delegate: self)
            cell.setImageView(updateProductViewModel: updateProductViewModel, indexPath: indexPath)

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as? TextCell else {
                return emptyCell
            }
            
            cell.setElement(updateProductViewModel: updateProductViewModel)
            cell.delegate = self
            cell.setUpDelegate()

            return cell
        }
    }
}

extension UpdateProductViewController: TextCellDelegate {
    func observeSegmentIndex(value: String) {
        updateProductViewModel.setProductInputCurrency(with: value)
    }
}

extension UpdateProductViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
        cell.present(imagePickerController: imagePickerController)
    }
}

extension UpdateProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController.pickImage(picker,
                                        didFinishPickingMediaWithInfo: info,
                                        updateProductViewModel: updateProductViewModel)
    }
}

extension UpdateProductViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateProductViewModel.setProductInput(textField: textField)
    }
}

extension UpdateProductViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateProductViewModel.setDescriptions(with: textView.text)
    }
}

extension UpdateProductViewController: ImageCellDelegate {
    func present(imagePickerController: ImagePickerController) {
        present(imagePickerController.getImagePicker(), animated: true)
    }
}
