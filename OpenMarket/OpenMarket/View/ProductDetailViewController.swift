//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/28.
//

import UIKit

private enum UserInformation {
    static let identifier: String = "affb87d9-d1b7-11ec-9676-d3cd1a738d6f"
    static var secret: String = "c7ne65d5oc"
}

private enum Alert {
    static let productDelete = "상품삭제"
    static let inputPassword = "비밀번호 입력"
    static let inputPasswordMessage = "비밀번호를 입력하세요"
    static let successDelete = "삭제 성공"
    static let successDeleteMessage = "상품을 삭제했습니다"
    static let failureDelete = "삭제 실패"
    static let failureDeleteMessage = "상품을 삭제하지 못했습니다"
    static let wrongPassword = "비밀번호 불일치"
    static let wrongPasswordMessage = "비밀번호가 틀렸습니다"
    static let ok = "OK"
    static let cancel = "취소"
    static let edit = "수정"
    static let delete = "삭제"
}

final class ProductDetailViewController: UIViewController {
    private let products: Products
    private var productDetail: ProductDetail?
    private var networkManager = NetworkManager()
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelButtonDidTapped(_:)))
    private var presenter = Presenter()
    private let productDetailView = ProductDetailView()
    
    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        
        return scrollView
    }()
    
    init(products: Products) {
        self.products = products
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.delegate = self
        setView()
        showProductDetail()
        setLayout()
        configureBarButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setData()
        setScrollView()
    }
    
    private func showProductDetail() {
        guard let id = self.products.id else {
            return
        }
        
        let getAPI = Detail(productId: id)
        
        self.networkManager.execute(with: getAPI) { result in
            switch result {
            case .success(let data):
                let decodedData = try? JSONDecoder().decode(ProductDetail.self, from: data)
                guard let result = decodedData else {
                    return
                }
                self.productDetail = result 
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func editButtonDidTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: Alert.edit, style: .default) {_ in
            guard let productDetail = self.productDetail else {
                return
            }
            
            let productEditViewController = ProductEditViewController(productDetail: productDetail)

            self.navigationController?.pushViewController(productEditViewController, animated: true)
        }
        
        let delete = UIAlertAction(title: Alert.delete, style: .destructive) {_ in
            let alert = UIAlertController(title: Alert.productDelete, message: Alert.inputPassword, preferredStyle: .alert)
            let delete = UIAlertAction(title: Alert.delete, style: .destructive) {_ in
                guard let secret = alert.textFields?.first?.text else {
                    return
                }
                self.checkPassword(secret: secret) { result in
                    switch result {
                    case .success(let secret):
                        self.deleteButtonDidTapped(secret: secret)
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.showWrongPasswordAlert()
                        }
                    }
                }
            }
            
            let cancel = UIAlertAction(title: Alert.cancel, style: .cancel, handler: nil)
            alert.addTextField { passwordTextField in
                passwordTextField.placeholder = Alert.inputPasswordMessage
            }
            
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: Alert.cancel, style: .cancel) {_ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(edit)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func cancelButtonDidTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Set UI
extension ProductDetailViewController {
    private func setData() {
        guard let productDetail = productDetail else {
            return
        }
        
        presenter = presenter.setData(of: productDetail)
        productDetailView.setDetailView(presenter)
        configurePriceUI()
        configureProductNameUI()
        configureStockUI()
    }
    
    private func setView() {
        self.view.addSubview(imageScrollView)
        self.view.addSubview(productDetailView)
        
        self.view.backgroundColor = .white
        productDetailView.backgroundColor = .white
    }
    
    private func setLayout() {
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        productDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageScrollView.bottomAnchor.constraint(equalTo: productDetailView.topAnchor, constant: -10),
            imageScrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4)
        ])
        
        NSLayoutConstraint.activate([
            productDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            productDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            productDetailView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setScrollView() {
        guard let images = presenter.images else {
            return
        }
        for index in 0..<images.count {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            imageView.frame = CGRect(
                x: self.view.frame.width * CGFloat(index),
                y: 0,
                width: imageScrollView.frame.width,
                height: imageScrollView.frame.height
            )
            imageScrollView.contentSize.width = imageView.frame.width * CGFloat(index + 1)
            
            guard let imageURL = images[index].url else { return }
            imageView.loadImage(imageURL)
            
            imageScrollView.addSubview(imageView)
        }
    }
    
    private func configureBarButton() {
        let editButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(editButtonDidTapped))
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.backBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    private func configurePriceUI() {
        let price = Int(presenter.price ?? "0")
        let discountedPrice = Int(presenter.discountedPrice ?? "0")
        
        guard let formattedPrice = price?.formatNumber() ,let formattedDiscountedPrice = discountedPrice?.formatNumber(), let currency = presenter.currency else { return }
        
        if presenter.price == presenter.bargainPrice {
            productDetailView.priceLabel.text = "\(currency) \(formattedPrice)"
            
            productDetailView.priceLabel.textColor = .black
            
            productDetailView.discountedLabel.isHidden = true
        } else {
            productDetailView.priceLabel.text = "\(currency) \(formattedPrice)"
            productDetailView.discountedLabel.text = "\(currency) \(formattedDiscountedPrice)"
            
            productDetailView.priceLabel.attributedText = productDetailView.priceLabel.text?.strikeThrough()
            
            productDetailView.priceLabel.textColor = .systemRed
            productDetailView.discountedLabel.textColor = .black
        }
    }
    
    private func configureProductNameUI() {
        productDetailView.productNameLabel.font = .systemFont(ofSize: 15, weight: .bold)
    }
    
    private func configureStockUI() {
        productDetailView.stockLabel.textColor = .systemGray2
    }
}

// MARK: - DELETE
extension ProductDetailViewController {
    private func checkPassword(secret: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
        guard let productId = products.id else {
            return
        }
        
        let postAPI = Secret(productId: productId)
        
        self.networkManager.execute(with: postAPI) { result in
            switch result {
            case .success(let secret):
                let data = secret
                
                guard let secret = String(data: data, encoding: .utf8) else {
                    return
                }
                
                UserInformation.secret = secret
                completionHandler(.success(UserInformation.secret))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    @objc private func deleteButtonDidTapped(secret: String) {
        guard let productId = products.id else {
            return
        }
        
        let deleteAPI = Delete(productId: productId, secret: UserInformation.secret)
        
        self.networkManager.execute(with: deleteAPI) {
            result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showSuccessAlert()
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showFailureAlert()
                }
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: Alert.successDelete, message: Alert.successDeleteMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.ok, style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    private func showFailureAlert() {
        let alert = UIAlertController(title: Alert.failureDelete, message: Alert.failureDeleteMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.ok, style: .default))
        self.present(alert, animated: true)
    }
    
    private func showWrongPasswordAlert() {
        let alert = UIAlertController(title: Alert.wrongPassword, message: Alert.wrongPasswordMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.ok, style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension ProductDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let size = imageScrollView.contentOffset.x / self.view.frame.width
        productDetailView.pageControl.currentPage = Int(round(size))
    }
}
