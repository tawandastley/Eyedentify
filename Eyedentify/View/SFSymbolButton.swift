//
//  DesignableFAB.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/08/19.
//
import UIKit

protocol SFSymbolButtonDelegate: AnyObject {
    func FABTapped()
}
class SFSymbolButton: UIButton {

    private var symbolName: String = ""
    weak var delegate: SFSymbolButtonDelegate?
    
    convenience init(symbolName: String) {
        self.init()
        self.symbolName = symbolName
        configureButton()
    }

    private func configureButton() {
        // Set up the button
        frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        backgroundColor = .clear

        // Use an SF Symbol as the mask
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)

        setImage(symbolImage, for: .normal)
        tintColor = UIColor(white: 0.2, alpha: 0.5)
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        // Handle button tap
        delegate?.FABTapped()
    }
}

