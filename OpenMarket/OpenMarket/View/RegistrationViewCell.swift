//
//  RegistrationViewCell.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/24.
//

import UIKit

final class RegistrationViewCell: UICollectionViewCell {
    static let identifier = "RegistrationViewCell"
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        makeProductImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeProductImage() {
        imageView.image = UIImage(systemName: "swift")
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        imageView.isUserInteractionEnabled = true
    }
}
