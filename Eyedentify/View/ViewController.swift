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
    @IBOutlet var containerView: UIView!
    var classificationResults : [String] = []
    let viewModel = ImageClassificationViewModel()
    let imagePicker = UIImagePickerController()
    private var animationView: LottieAnimationView!
    var symbolButton: SFSymbolButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        imagePicker.delegate = self
        createFloatingActionButton()
        setupAnimation()
        imageView.isHidden = true
        symbolButton.isHidden = true
        titleLabel.text = "SelectSource".localized
        
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
        symbolButton.isHidden = false
        if let pickedImage = info[.originalImage] as? UIImage {
            guard let image = CIImage(image: pickedImage) else {
                return
            }
            viewModel.detectImage(image: image, completion: { results in
                //                if let firstResult = results.first {
                //                    let confidence = firstResult.confidence.rounded() * 100
                //
                //                    if confidence  < 50 {
                //                        self.titleLabel.text = "\(firstResult.identifier) ??? \nConfidence: 🫣"
                //                        self.titleLabel.font = .italicSystemFont(ofSize: 20)
                //                        self.titleLabel.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
                //
                //                    } else {
                //                        self.titleLabel.text = "\(firstResult.identifier.uppercased()) \nConfidence: \(confidence)% 😎"
                //                        self.titleLabel.font = .boldSystemFont(ofSize: 20)
                //                        self.titleLabel.textColor = .lightText
                //                        self.titleLabel.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
                //                        self.titleLabel.layer.cornerRadius = 5
                //                    }
                //
                //                }
                var yOffset: CGFloat = 20.0 // Initial y-offset
                while results.count <= 5 {
                    for text in results {
                        
                        let label = UILabel()
                        label.frame = CGRect(x: 20, y: yOffset, width: self.containerView.frame.width - 40, height: 30)
                        label.text = text.identifier
                        label.textColor = UIColor.black
                        label.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
                        self.containerView.addSubview(label)
                        
                        yOffset += label.frame.height + 1 // Increase y-offset for the next label
                    }
                }
                self.titleLabel.text = results.first?.identifier
                self.imageView.image = pickedImage
                self.imageView.contentMode = .scaleAspectFit
                self.addSwipeGestures()
            })
            
        }
        imagePicker.dismiss(animated: true)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            viewModel.showAlert(title: "Error".localized, message: "Error saving image: \(error.localizedDescription)")
        } else {
            viewModel.showAlert(title: "Success", message: "Image saved successfully.")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

extension ViewController: SFSymbolButtonDelegate {
    
    func FABTapped() {
        symbolButton.isHidden = false
        guard let screenshot = takeScreenshot() else {
            symbolButton.isHidden = true
            return
        }
        symbolButton.isHidden = false
        // Share the screenshot
        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        let twitterType = UIActivity.ActivityType(rawValue: "com.apple.social.twitter")
        activityViewController.excludedActivityTypes?.append(twitterType)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = symbolButton.frame
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    func takeScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let screenshot = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            symbolButton.isHidden = true
        }
        
        return screenshot
    }
    
    //MARK: Private methods
    
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
            viewModel.showAlert(title: "Error".localized, message: "CameraError".localized)
        }
    }
    
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = [UTType.image.identifier as String]
            self.present(imagePicker, animated: true)
        }
        else {
            viewModel.showAlert(title: "Warning".localized, message: "GalleryError".localized)
        }
    }
    
    private func setupAnimation() {
        animationView = .init(name: "scanAnimation")
        animationView.translatesAutoresizingMaskIntoConstraints = false // Add this line
        view.addSubview(animationView)
        
        // Set up constraints to center the animationView
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5), // Adjust the multiplier as needed
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor) // Maintain aspect ratio
        ])
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        animationView.play()
    }
    
    private func hideAnimation() {
        animationView.stop()
        animationView.isHidden = true
        imageView.isHidden = false
    }
    
    private func showAnimation() {
        
        titleLabel.text = "SelectSource".localized
        animationView.play()
        animationView.isHidden = false
        imageView.isHidden = true
        symbolButton.isHidden = true
    }
    
    private func addSwipeGestures() {
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(performGesture(_:)))
        gesture.direction = .right
        imageView.addGestureRecognizer(gesture)
        imageView.isUserInteractionEnabled = true
        
    }
    
    private func createFloatingActionButton() {
        symbolButton = SFSymbolButton(symbolName: "square.and.arrow.up.fill")
        symbolButton.tintColor = .label
        symbolButton.delegate = self
        symbolButton.translatesAutoresizingMaskIntoConstraints = false
        symbolButton.isHidden = true
        view.addSubview(symbolButton)
        symbolButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        symbolButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
    }
    
    @objc private func performGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            showAnimation()
        }
    }
}
