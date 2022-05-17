//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

enum Section: Int {
    case main
}

struct Product: APIable {
    var hostAPI: String = "https://market-training.yagom-academy.kr"
    var path: String = "/api/products"
    var param: [String : String]? = [
        "page_no": "1",
        "items_per_page": "10"
    ]
    var method: HTTPMethod = .get
}

final class ViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ProductsDetail>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ProductsDetail>
    
    lazy var productView = ProductView.init(frame: view.bounds)
    private lazy var dataSource = makeDataSource()
    let networkManager = NetworkManager<Products>(session: URLSession.shared)
    var item: [ProductsDetail] = []{
        didSet {
            DispatchQueue.main.async {
                self.applySnapshot()
            }
        }
    }
    let product = Product()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        productView.collectionView.dataSource = self.dataSource
        productView.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global().async {
            self.networkManager.execute(with: self.product) { result in
                switch result {
                case .success(let result):
                    self.item = result.pages
                    dispatchGroup.leave()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        applySnapshot()
    }
    
    private func configureView() {
        self.view = productView
        view.backgroundColor = .white
        navigationItem.titleView = productView.segmentedControl
        navigationItem.rightBarButtonItem = productView.plusButton
        
        NSLayoutConstraint.activate([
            productView.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            productView.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            productView.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            productView.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        productView.configureLayout()
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: productView.collectionView,
            cellProvider: { (collectionView, indexPath, productDetail) -> UICollectionViewCell? in
                guard let cell = self.productView.collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configurePriceUI()
                cell.configureProductUI()
                cell.configureProductWithImageUI()
                cell.configureAccessoryStackView()
                
//                self.item.forEach { product in
//                    cell.currency.text = product.currency
//                    cell.price.text = String(product.price)
//                    cell.bargainPrice.text = String(product.bargainPrice)
//                    cell.stock.text = String(product.stock)
//
//                    guard let data = try? Data(contentsOf: product.thumbnail) else {
//                        return
//                    }
//                    cell.productImage.image = UIImage(data: data)
//                }
                
                cell.productName.text = self.item[indexPath.row].name
                cell.currency.text = self.item[indexPath.row].currency
                cell.price.text = String(self.item[indexPath.row].price)
                cell.bargainPrice.text = String(self.item[indexPath.row].bargainPrice)
                cell.stock.text = String(self.item[indexPath.row].stock)
                
                guard let data = try? Data(contentsOf: self.item[indexPath.row].thumbnail) else {
                    return UICollectionViewCell()
                }
                
                cell.productImage.image = UIImage(data: data)
                
//                cell.currency.text = "currency"
//                cell.price.text = "price"
//                cell.bargainPrice.text = "bargainPrice"
//                cell.stock.text = "stock"
//
//                print("\(cell.currency.text)")
                return cell
            })
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapShot = Snapshot()
        snapShot.appendSections([Section.main])
        snapShot.appendItems(item, toSection: Section.main)
        dataSource.apply(snapShot, animatingDifferences: animatingDifferences)
    }
}
