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
    
    private lazy var priceStackView = makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 3)
    private lazy var productStackView = makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 5)
    
    private lazy var stockName: UILabel = {
        let label = UILabel()
        if stock.text == "0" {
            label.text = "품절"
        } else {
            label.text = "잔여수량: \(stock)"
        }
        
        return label
    }()
    
    private func makeStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        
        return stackView
    }
    
    func configurePriceUI() {
        priceStackView.addArrangedSubview(currency)
        priceStackView.addArrangedSubview(price)
    }
    
    func configureProductUI() {
        productStackView.addArrangedSubview(productImage)
        productStackView.addArrangedSubview(productName)
        productStackView.addArrangedSubview(priceStackView)
        productStackView.addArrangedSubview(stockName)
        self.contentView.addSubview(productStackView)
        
        NSLayoutConstraint.activate([
            productStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            productStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            productStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            productStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
        
        NSLayoutConstraint.activate([
            productImage.widthAnchor.constraint(equalToConstant: 100),
            productImage.heightAnchor.constraint(equalTo: productImage.widthAnchor)
        ])
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
