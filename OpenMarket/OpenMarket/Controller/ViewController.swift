//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class ViewController: UIViewController {

    let productView = ProductView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productView.backgroundColor = .white
        navigationItem.titleView = productView.makeSegmentedControl()
        navigationItem.rightBarButtonItem = productView.makePlusButton()
    }
}

