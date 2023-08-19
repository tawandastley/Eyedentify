//
//  LabelDesignable.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/08/15.
//

import UIKit

@IBDesignable
class DesignableLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateFont()
    }
    
    @IBInspectable var fontSize: CGFloat = 17 {
        didSet {
            updateFont()
        }
    }
    
    @IBInspectable var labelBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = labelBackgroundColor
        }
    }
    
    @IBInspectable var labelAlpha: CGFloat = 1.0 {
        didSet {
            alpha = labelAlpha
        }
    }
    
    @IBInspectable var labelWhite: CGFloat = 1.0 {
        didSet {
            tintColor = .white
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var boldFont: String? {
        didSet {
            if let fontName = boldFont {
                let fontSize = self.font.pointSize
                self.font = UIFont(name: fontName, size: fontSize)
            }
        }
    }
    
    private func updateFont() {
        font = font.withSize(fontSize)
    }
}
