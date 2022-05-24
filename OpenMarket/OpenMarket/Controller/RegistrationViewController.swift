//
//  RegistrationViewController.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/24.
//

import UIKit

final class RegistrationViewController: UIViewController {
    private lazy var registrationViewCell = RegistrationViewCell(frame: view.bounds)
    private lazy var productDetailView = ProductDetailView(frame: view.bounds)
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemRed
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        configureNavigation(title: "상품등록")
        collectionView.register(RegistrationViewCell.self, forCellWithReuseIdentifier: RegistrationViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        configureView()
    }
    
    private func configureView() {
        self.view = productDetailView
        self.view.addSubview(collectionView)
//        self.view.addSubview(productDetailView)
        self.view.backgroundColor = UIColor.white
        
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -300)
        ])
        
        NSLayoutConstraint.activate([
            productDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            productDetailView.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor),
            productDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            productDetailView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension RegistrationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegistrationViewCell.identifier, for: indexPath) as? RegistrationViewCell else { return UICollectionViewCell() }
        
        cell.makeProductImage()
        
        return cell
    }
}

extension RegistrationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

extension RegistrationViewController {
    func configureNavigation(title: String) {
        self.title = title
        
        let leftNavigationButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        let rightNavigationButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        
        self.navigationItem.leftBarButtonItem = leftNavigationButton
        self.navigationItem.rightBarButtonItem = rightNavigationButton
    }
}
