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
        addSwipeGestures()
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
                if let firstResult = results.first {
                    let confidence = firstResult.confidence.rounded() * 100
                    
                    if confidence  < 50 {
                        self.titleLabel.text = "\(firstResult.identifier) ??? \nConfidence: 🫣"
                        self.titleLabel.font = .italicSystemFont(ofSize: 20)
                        self.titleLabel.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
                        
                    } else {
                        self.titleLabel.text = "\(firstResult.identifier.uppercased()) \nConfidence: \(confidence)% 😎"
                        self.titleLabel.font = .boldSystemFont(ofSize: 20)
                        self.titleLabel.textColor = .lightText
                        self.titleLabel.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
                        self.titleLabel.layer.cornerRadius = 5
                        print("https://factanimal.com/\(firstResult.identifier)")
                    }
                    
                }
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
        shareScreenshot(screenshot: screenshot)
        
    }
    
    //MARK: Camera and Gallery
    
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
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }
        else {
            viewModel.showAlert(title: "Warning".localized, message: "GalleryError".localized)
        }
    }
    
    func takeScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let screenshot = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            symbolButton.isHidden = true
        }
        
        return screenshot
    }
    
    private func shareScreenshot(screenshot: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        let twitterType = UIActivity.ActivityType(rawValue: "com.apple.social.twitter")
        activityViewController.excludedActivityTypes?.append(twitterType)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = symbolButton.frame
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: Animations and Floating Action Button
    
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
    
    private func setupAnimation() {
        animationView = .init(name: "scanAnimation")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
            NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5),
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor)
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
    
    // MARK: Swipe Gestures
    
    private func addSwipeGestures() {
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(_:)))
        rightGesture.view?.backgroundColor = .blue
        rightGesture.direction = .right
        imageView.addGestureRecognizer(rightGesture)
        imageView.isUserInteractionEnabled = true
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe(_:)))
        leftGesture.view?.backgroundColor = .red
        leftGesture.direction = .left
        imageView.addGestureRecognizer(leftGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func handleLeftSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            showAnimation()
        }
    }
    
    @objc func handleRightSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            guard let image = takeScreenshot() else {
                viewModel.showAlert(title: "Error".localized, message: "Select image to analyze")
                return
            }
            shareScreenshot(screenshot: image)
        }
    }
}
