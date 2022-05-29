//
//  ProductEditView.swift
//  OpenMarket
//
//  Created by marisol on 2022/05/28.
//

import UIKit

final class ProductEditView: UIView, Drawable {
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
    func generateParameters() -> PatchRequest {
            let name = self.productNameTextField.text ?? ""
            let description = self.descriptionTextView.text ?? ""
            let priceString = self.priceTextField.text ?? ""
            let price = Int(priceString) ?? 0
            let currency = self.segmentedControl.selectedSegmentIndex == 0 ? Currency.KRW : Currency.USD
            let discountedPriceString = self.discountedPriceTextField.text ?? ""
            let discountedPrice = Int(discountedPriceString) ?? 0
            let stockString = self.stockTextField.text ?? ""
            let stock = Int(stockString) ?? 0
            let secret = "c7ne65d5oc"
        
        return PatchRequest(name: name, description: description, thumbnailID: nil , price: price, currency: currency, discountedPrice: discountedPrice, stock: stock, secret: secret)
    }
}
