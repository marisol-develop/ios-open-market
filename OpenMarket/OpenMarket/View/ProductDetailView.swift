//
//  ProductDetailView.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/24.
//

import UIKit

enum Currency: String {
    case KRW
    case USD
}

enum PlaceHolder: String {
    case productName = "상품명"
    case price = "상품가격"
    case discountedPrice = "할인금액"
    case stock = "재고수량"
}

final class ProductDetailView: UIView {
    private lazy var entireStackView = makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 20)
    private lazy var productInfoStackView = makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 10)
    private lazy var priceStackView = makeStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 3)
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.isEditable = true
        
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(entireStackView)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePriceStackView() {
        let textField = UITextField()
        let segmentedContol = UISegmentedControl(items: [Currency.KRW.rawValue, Currency.USD.rawValue])
        
        textField.borderStyle = .roundedRect
        textField.placeholder = PlaceHolder.price.rawValue
        segmentedContol.selectedSegmentIndex = 0
        
        segmentedContol.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        segmentedContol.setContentCompressionResistancePriority(.required, for: .horizontal)
        priceStackView.addArrangedSubview([textField, segmentedContol])
    }
    
    func configureProductInfoStackView() {
        let productNameTextField = UITextField()
        productNameTextField.borderStyle = .roundedRect
        productNameTextField.placeholder = PlaceHolder.productName.rawValue
        
        let discountedPriceTextField = UITextField()
        discountedPriceTextField.borderStyle = .roundedRect
        discountedPriceTextField.placeholder = PlaceHolder.discountedPrice.rawValue
        
        let stockTextField = UITextField()
        stockTextField.borderStyle = .roundedRect
        stockTextField.placeholder = PlaceHolder.stock.rawValue
        
        productInfoStackView.addArrangedSubview([productNameTextField, priceStackView, discountedPriceTextField, stockTextField])
    }
    
    func configureEntireStackView() {
        entireStackView.addArrangedSubview([ productInfoStackView, descriptionTextView])
        
        NSLayoutConstraint.activate([
            self.entireStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.entireStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
            self.entireStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.entireStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

extension ProductDetailView {
    private func makeStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        
        return stackView
    }
}
