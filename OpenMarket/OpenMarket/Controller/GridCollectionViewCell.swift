//
//  GridCollectionViewCell.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/18.
//

import UIKit

final class GridCollectionViewCell: UICollectionViewCell {
    static let identifier = "GridCollectionViewCell"
    var productImage: UIImageView = UIImageView()
    var productName: UILabel = UILabel()
    var currency: UILabel = UILabel()
    var price: UILabel = UILabel()
    var bargainPrice: UILabel = UILabel()
    var stock: UILabel = UILabel()

    private lazy var productStackView = makeStackView(axis: .vertical, alignment: .center, distribution: .equalSpacing, spacing: 5)
    private lazy var priceStackView = makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 3)
    
    func formatNumber(price: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let result = numberFormatter.string(from: NSNumber(value: price)) else {
            return ""
        }
        return result
    }
    
    lazy var originalPrice: UILabel = {
        let label = UILabel()
       
        guard let currency = currency.text else {
            return UILabel()
        }
        
        guard let price = price.text else {
            return UILabel()
        }
        
        label.textColor = .systemGray2
                
        return label
    }()
    
    lazy var discountedPrice: UILabel = {
        let label = UILabel()
       
        guard let currency = currency.text else {
            return UILabel()
        }
        guard let price = bargainPrice.text else {
            return UILabel()
        }
        
        label.textColor = .systemGray2
        
        return label
    }()

    private lazy var stockName: UILabel = {
        let label = UILabel()
        guard let stock = stock.text else {
            return UILabel()
        }
        
        if stock == "0" {
            label.text = "품절"
            label.textColor = .systemYellow
            
        } else {
            label.text = "잔여수량: \(stock)"
            label.textColor = .systemGray2
        }
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.systemGray5.cgColor
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.image = nil
        productName.text = nil
        currency.text = nil
        price.text = nil
        bargainPrice.text = nil
        stock.text = nil
        
        updateLayout()
    }
    
    func updateLayout() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func configureCell(_ productDetail: ProductsDetail) {
        if productDetail.discountedPrice != 0 {
            let currency = productDetail.currency
            let price = formatNumber(price: productDetail.price)
            let bargain = formatNumber(price: productDetail.bargainPrice)
        
            originalPrice.text = "\(currency) \(price)"
            makeBargainPrice(price: originalPrice)
            discountedPrice.text = "\(currency) \(bargain)"
            discountedPrice.textColor = .systemGray2
        } else {
            let currency = productDetail.currency
            let formattedPrice = formatNumber(price: productDetail.price)
            let price = formattedPrice
            
            originalPrice.text = "\(currency) \(price)"
            originalPrice.textColor = .systemGray2
        }
        productName.font  = UIFont.boldSystemFont(ofSize: 20)
        productName.text = productDetail.name
        stock.text = String(productDetail.stock)
        
        guard let data = try? Data(contentsOf: productDetail.thumbnail) else {
            return
        }
        
        productImage.image = UIImage(data: data)
        
        configureProductUI()
        configurePriceUI()
    }
    
    func makeBargainPrice(price: UILabel) {
        price.textColor = .systemRed
        price.attributedText = price.text?.strikeThrough()
    }
    
    private func makeStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        
        return stackView
    }
    
    func configureProductUI() {
        productStackView.addArrangedSubview(productImage)
        productStackView.addArrangedSubview(productName)
        productStackView.addArrangedSubview(priceStackView)
        productStackView.addArrangedSubview(stockName)
        self.contentView.addSubview(productStackView)
        
        NSLayoutConstraint.activate([
            productStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            productStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            productStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            productStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            productImage.widthAnchor.constraint(equalToConstant: 100),
            productImage.heightAnchor.constraint(equalTo: productImage.widthAnchor)
        ])
    }
    
    func configurePriceUI() {
        priceStackView.addArrangedSubview(originalPrice)
        priceStackView.addArrangedSubview(discountedPrice)
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSMakeRange(0,attributeString.length)
        )
        return attributeString
    }
}
