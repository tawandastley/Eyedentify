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
        if let pickedImage = info[.originalImage] as? UIImage {
            guard let image = CIImage(image: pickedImage) else {
                print("unsupported image")
                return
            }
            detectImage(image: image)
            imageView.image = pickedImage
            imageView.contentMode = .scaleAspectFit
            AddSwipeGestures()
        }
        imagePicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
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
                
                if confidence  < 50 {
                    self.titleLabel.text = "\(firstResult.identifier.lowercased()) ??? \n\nConfidence: \(confidence)% 😩"
                    self.titleLabel.font = .italicSystemFont(ofSize: 20)
                    DispatchQueue.main.async {
                        Alerts.showAlert(title: "⚠️", message: "Please try again or choose a different image")
                    }
                } else {
                    self.titleLabel.text = "\(firstResult.identifier.uppercased()) \n\nConfidence: \(confidence)% 😎"
                    self.titleLabel.font = .boldSystemFont(ofSize: 20)
                    self.titleLabel.textColor = .lightText
                    self.titleLabel.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
                    self.titleLabel.layer.cornerRadius = 5
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            Alerts.showAlert(title: "Error", message: error.localizedDescription)
        }
        
    }
    private func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            imagePicker.sourceType = .camera
            imagePicker.cameraDevice = .rear
            imagePicker.cameraFlashMode = .auto
            imagePicker.mediaTypes = [UTType.image.identifier]
            imagePicker.delegate = self // Don't forget this line
            present(imagePicker, animated: true)
        }
        else {
            Alerts.showAlert(title: "Error", message: "Failed to access the camera.")
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
            Alerts.showAlert(title: "Warning", message: "You don't have permission to access gallery.")
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
    
    private func AddSwipeGestures() {
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(PerformGesture(_ :)))
        gesture.direction = .right
        imageView.addGestureRecognizer(gesture)
        imageView.isUserInteractionEnabled = true
        
    }
    
    @objc private func PerformGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .left {
            showAnimation()
        } else if gesture.direction == .right{
            showAnimation()
        }
    }
    
}
