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
        self.view = productView
        view.backgroundColor = .white
        navigationItem.titleView = productView.makeSegmentedControl()
        navigationItem.rightBarButtonItem = productView.makePlusButton()
        view.addSubview(productView.makeCollectionView())
        productView.makeLayout()
    }
}
