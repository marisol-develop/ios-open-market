//
//  RegistrationViewController.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/24.
//

import UIKit

class RegistrationViewController: UIViewController {
    let rightNavigationButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    let productDetailView = ProductDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        self.view.addSubview(productDetailView)
        productDetailView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RegistrationViewCell.self, forCellWithReuseIdentifier: RegistrationViewCell.identifier)
        setLayout()
        self.navigationController?.navigationBar.topItem?.title = "Cancel"
        self.title = "상품등록"
        self.navigationItem.rightBarButtonItem = rightNavigationButton
        rightNavigationButton.isEnabled = false
    }
    
    func setLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        productDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: productDetailView.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 160),
            
            productDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productDetailView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            productDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension RegistrationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegistrationViewCell.identifier, for: indexPath) as? RegistrationViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
}

extension RegistrationViewController: UICollectionViewDelegateFlowLayout {
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
