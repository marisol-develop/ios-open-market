//
//  String+.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/19.
//

import UIKit

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSMakeRange(0,attributeString.length)
        )
        return attributeString
    }
}
