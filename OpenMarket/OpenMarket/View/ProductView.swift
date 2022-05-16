//
//  ProductView.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/16.
//

import UIKit

class ProductView: UIView {
    
    func makeSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: ["LIST", "GRID"])
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = .systemBlue
        
        return segmentedControl
    }
    
    func makePlusButton() -> UIBarButtonItem {
        let plusButton = UIBarButtonItem()
        
        plusButton.title = "+"
        
        return plusButton
    }
}
