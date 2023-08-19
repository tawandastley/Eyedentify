//
//  ImageClassificationViewModel.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/08/19.
//

import UIKit
import CoreML
import Vision

class ImageClassificationViewModel {
    
    var classificationResults: [String] = []
    
    func detectImage(image: CIImage, completion: @escaping ([VNClassificationObservation]) -> Void){
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: .init()).model) else {
            showAlert(title: "Error", message: "An error occurred. The app will now exit.", exitOnError: true)
            return
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError()
            }
            
            completion(results)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            showAlert(title: "Error".localized, message: error.localizedDescription)
        }
        
    }
    
    func showAlert(title: String?, message: String?, exitOnError: Bool = false) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if exitOnError {
            let exitAction = UIAlertAction(title: "Exit", style: .destructive) { _ in
                fatalError("Forced app termination")
            }
            alertController.addAction(exitAction)
        }
        
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    
}
