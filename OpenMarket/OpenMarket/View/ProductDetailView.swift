//
//  ProductDetailView.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/06/02.
//

import UIKit

final class ProductDetailView: UIView {
    lazy var entireStackView = makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 20)
    lazy var priceStackView = makeStackView(axis: .vertical, alignment: .trailing, distribution: .fill, spacing: 3)
    lazy var productInfoStackView = makeStackView(axis: .horizontal, alignment: .top, distribution: .fill, spacing: 0)
    
    let entireScrollView = UIScrollView()
    private let productImage = UIImageView()
    let stockLabel = UILabel()
    let priceLabel = UILabel()
    let discountedLabel = UILabel()
    let productNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let currencyLabel = UILabel()
    let pageControl = UIPageControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configurePageControl()
        setAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDetailView(_ presenter: Presenter) {
        setStock(presenter)
        setDescription(presenter)
        setProductName(presenter)
        setPageControl(presenter)
    }
        
    private func setAttribute() {
        priceStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        discountedLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    private func configurePageControl() {
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
    }
}

extension ProductDetailView {
    private func configureView() {
        self.addSubview(pageControl)
        self.addSubview(entireScrollView)
        entireScrollView.addSubview(entireStackView)
        entireStackView.addArrangedSubview([
            productInfoStackView, descriptionLabel
        ])
        productInfoStackView.addArrangedSubview([
            productNameLabel, priceStackView
        ])
        
        priceStackView.addArrangedSubview([
            stockLabel, priceLabel, currencyLabel, discountedLabel
        ])
        
        configureLayout()
    }
    
    private func configureLayout() {
        entireScrollView.translatesAutoresizingMaskIntoConstraints = false
        entireStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            entireScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            entireScrollView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 10),
            entireScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            entireScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            entireStackView.leadingAnchor.constraint(equalTo: entireScrollView.contentLayoutGuide.leadingAnchor),
            entireStackView.topAnchor.constraint(equalTo: entireScrollView.contentLayoutGuide.topAnchor),
            entireStackView.trailingAnchor.constraint(equalTo: entireScrollView.contentLayoutGuide.trailingAnchor),
            entireStackView.bottomAnchor.constraint(equalTo: entireScrollView.contentLayoutGuide.bottomAnchor),
            entireStackView.widthAnchor.constraint(equalTo: entireScrollView.frameLayoutGuide.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pageControl.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }
}

extension ProductDetailView {
    private func setProductName(_ presenter: Presenter) {
        productNameLabel.text = presenter.productName
        productNameLabel.numberOfLines = 0
    }
    
    private func setStock(_ presenter: Presenter) {
        guard let stock = presenter.stock else { return }
        
        stockLabel.text = "남은 수량 : \(stock)"
    }
    
    private func setDescription(_ presenter: Presenter) {
        descriptionLabel.text = presenter.description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
    }
    
    private func setPageControl(_ presenter: Presenter) {
        pageControl.numberOfPages = presenter.images?.count ?? 0
    }
}

private extension ProductDetailView {
    func makeStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        
        return stackView
    }
}
