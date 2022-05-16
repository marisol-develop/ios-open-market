//
//  CollectionViewCell.swift
//  OpenMarket
//
//  Created by marisol on 2022/05/16.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "CollectionViewCell"
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var bargainPrice: UILabel!
    @IBOutlet weak var stock: UILabel!
}
