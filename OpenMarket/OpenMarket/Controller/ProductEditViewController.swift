//
//  ProductEditViewController.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/28.
//

import UIKit

final class ProductEditViewController: UIViewController {
    var productDetail: ProductDetail?
    private var networkImageArray = [ImageInfo]()
    private var networkManager = NetworkManager<ProductsList>(session: URLSession.shared)
    private var presenter = Presenter()
    
    private let productEditView = ProductEditView()
    private let doneButton = UIBarButtonItem()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    private let entireScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewDelegate()
        setView()
        setLayout()
        configureBarButton()
        setData()
    }
    
    private func setView() {
        self.view.addSubview(entireScrollView)
        entireScrollView.addSubview(collectionView)
        entireScrollView.addSubview(productEditView)
        
        self.view.backgroundColor = .white
        productEditView.backgroundColor = .white
        
        collectionView.register(EditViewCell.self, forCellWithReuseIdentifier: EditViewCell.identifier)
    }
    
    private func setViewDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureBarButton() {
        self.navigationController?.navigationBar.topItem?.title = "Cancel"
        self.title = "상품수정"
        self.navigationItem.rightBarButtonItem = doneButton
        
        doneButton.title = "Done"
        doneButton.style = .done
        doneButton.target = self
        doneButton.action = #selector(executePATCH)
    }
    
    private func setLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        productEditView.translatesAutoresizingMaskIntoConstraints = false
        entireScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            entireScrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            entireScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            entireScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            entireScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            entireScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            collectionView.widthAnchor.constraint(equalTo: entireScrollView.widthAnchor),
            collectionView.leadingAnchor.constraint(equalTo: entireScrollView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: entireScrollView.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: entireScrollView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: productEditView.topAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 160),
            
            productEditView.widthAnchor.constraint(equalTo: entireScrollView.widthAnchor),
            productEditView.leadingAnchor.constraint(equalTo: entireScrollView.leadingAnchor),
            productEditView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            productEditView.trailingAnchor.constraint(equalTo: entireScrollView.trailingAnchor),
            productEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setData() {
        guard let productDetail = productDetail else {
            return
        }
        
        presenter = presenter.setData(of: productDetail)
    }
}

extension ProductEditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditViewCell.identifier, for: indexPath) as? EditViewCell else {
            return UICollectionViewCell()
        }
//        cell.setImage(presenter.images?[indexPath.row])
        productEditView.setEditView(presenter)
        
        return cell
    }
}

extension ProductEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

extension ProductEditViewController {
    @objc private func executePATCH() {
        let params = productEditView.generateParameters()
        
        DispatchQueue.global().async {
            guard let productID = self.productDetail?.id else {
                return
            }
            
            self.networkManager.execute(with: .productEdit(productId: productID), httpMethod: .patch, params: params) { result in
                switch result {
                case .success:
                    print("success")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}
