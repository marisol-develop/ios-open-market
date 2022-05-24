//
//  RegistrationViewCell.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/24.
//

import UIKit

final class RegistrationViewCell: UICollectionViewCell {
    static let identifier = "RegistrationViewCell"
    
    func makeProductImage() {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 100),
            image.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
