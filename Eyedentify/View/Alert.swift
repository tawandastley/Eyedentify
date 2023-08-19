//
//  Alert.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/08/19.
//

import UIKit

struct Alert {
    static func showAlert(title: String?, message: String?, completion: (() -> Void)? = nil) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localized, style: .default) { _ in
            completion?()
        }
        alertController.addAction(action)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
}
