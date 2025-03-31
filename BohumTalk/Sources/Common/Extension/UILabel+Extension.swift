//
//  UILabel+Extension.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit

extension UILabel {
    func design(text: String = "", textColor: UIColor = .black, font: UIFont = .systemFont(ofSize: 14),  textAlignment: NSTextAlignment = .left, numberOfLines: Int = 1) {
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }
    
    func setLineSpacing(spacing: CGFloat) {
       guard let text = text else { return }

       let attributeString = NSMutableAttributedString(string: text)
       let style = NSMutableParagraphStyle()
       style.lineSpacing = spacing
       attributeString.addAttribute(.paragraphStyle,
                                    value: style,
                                    range: NSRange(location: 0, length: attributeString.length))
       attributedText = attributeString
    }
}
