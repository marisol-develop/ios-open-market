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
                
                cell.productName.text = productDetail.name
                cell.currency.text = productDetail.currency
                cell.price.text = String(productDetail.price)
                cell.bargainPrice.text = String(productDetail.bargainPrice)
                cell.stock.text = String(productDetail.stock)
                
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
