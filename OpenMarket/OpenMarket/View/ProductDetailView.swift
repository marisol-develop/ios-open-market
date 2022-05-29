//
//  ProductDetailView.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/24.
//

import UIKit

enum Currency: String, Encodable {
    case KRW = "KRW"
    case USD = "USD"
}

enum PlaceHolder: String {
    case productName = "상품명"
    case price = "상품가격"
    case discountedPrice = "할인금액"
    case stock = "재고수량"
}

final class ProductDetailView: UIView, Drawable {
    lazy var entireStackView = makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 20)
    lazy var productInfoStackView = makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 10)
    lazy var priceStackView = makeStackView(axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 3)
    let priceTextField = UITextField()
    let segmentedControl = UISegmentedControl(items: [Currency.KRW.rawValue, Currency.USD.rawValue])
    let productNameTextField = UITextField()
    let discountedPriceTextField = UITextField()
    let stockTextField = UITextField()
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        
        textView.isEditable = true
        
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
