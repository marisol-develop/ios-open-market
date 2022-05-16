//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class ViewController: UIViewController {
    lazy var productView = ProductView.init(frame: view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        self.view = productView
        view.backgroundColor = .white
        navigationItem.titleView = productView.segmentedControl
        navigationItem.rightBarButtonItem = productView.plusButton
        view.addSubview(productView.collectionView)
        productView.configureLayout()
    }
}
