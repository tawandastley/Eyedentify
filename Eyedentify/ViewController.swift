//
//  ViewController.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/06/04.
//

import UIKit
import CoreML
import Vision
import AVFoundation
//import MobileCoreServices
//import UniformTypeIdentifiers
import Lottie

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    private var animationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isHidden = true
        titleLabel.text = "Select Source"
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        setupAnimation()
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        openCamera()
    }
    
    @IBAction func galleryTapped(_ sender: Any) {
        openGallery()
    }
    
    //MARK: Delegate methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        hideAnimation()
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            guard let image = CIImage(image: pickedImage) else {
                return
            }
            detectImage(image: image)
        }
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { _ in
            self.showAnimation()
        }
        imagePicker.dismiss(animated: true)
    }
    
    //MARK: Private methods
    
    private func detectImage(image: CIImage){
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: .init()).model) else {
            fatalError()
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError()
            }
            if let firstResult = results.first {
                let confidence = firstResult.confidence.rounded() * 100
                self.titleLabel.text = "\(firstResult.identifier.uppercased()) \n\nConfidence: \t\(confidence)% "
                self.titleLabel.font = .boldSystemFont(ofSize: 20)
                self.titleLabel.textColor = .lightText
                self.titleLabel.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
                self.titleLabel.layer.cornerRadius = 5
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            let alert = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
        
    }
    private func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.dismiss(animated: true)
  
        }
        else {
            let alert  = UIAlertController(title: "Error",
                                           message: "Failed to access the camera.",
                                           preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.mediaTypes = [UTType.image.identifier as String]
            imagePicker.dismiss(animated: true)
            self.present(imagePicker, animated: true)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
   private func setupAnimation() {
        animationView = .init(name: "scanAnimation")
        animationView.frame = imageView.frame
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        view.addSubview(animationView)
        animationView.play()
    }
    
    private func hideAnimation() {
        animationView.stop()
        animationView.isHidden = true
        imageView.isHidden = false
    }
    private func showAnimation() {
        titleLabel.text = "Select Source"
        animationView.play()
        animationView.isHidden = false
        imageView.isHidden = true
    }
}
