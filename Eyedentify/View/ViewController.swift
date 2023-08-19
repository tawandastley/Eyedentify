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
    let imagePicker = UIImagePickerController()
    private var animationView: LottieAnimationView!
    var symbolButton: SFSymbolButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        imagePicker.delegate = self
        createFloatingActionButton()
        setupAnimation()
        imageView.isHidden = true
        titleLabel.text = "SelectSource".localized
        symbolButton = SFSymbolButton(symbolName: "square.and.arrow.up")
        symbolButton.tintColor = .label
        symbolButton.delegate = self
        symbolButton.translatesAutoresizingMaskIntoConstraints = false
        symbolButton.isHidden = true
        view.addSubview(symbolButton)
        symbolButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        symbolButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
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
            detectImage(image: image)
            imageView.image = pickedImage
            imageView.contentMode = .scaleAspectFit
            addSwipeGestures()
        }
        imagePicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

extension ViewController: SFSymbolButtonDelegate {
    
    func FABTapped() {
        symbolButton.isHidden = true
        guard let screenshot = takeScreenshot() else {
            symbolButton.isHidden = true
            return
        }
        symbolButton.isHidden = true
        // Share the screenshot
        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
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

@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
        Alert.showAlert(title: "Error".localized, message: "Error saving image: \(error.localizedDescription)")
    } else {
        Alert.showAlert(title: "Success", message: "Image saved successfully.")
    }
}
//MARK: Private methods

private func detectImage(image: CIImage){
    guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: .init()).model) else {
        showAlertAndExit()
        return
    }
    let request = VNCoreMLRequest(model: model) { [self] request, error in
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError()
        }
        if let firstResult = results.first {
            let confidence = firstResult.confidence.rounded() * 100
            
            if confidence  < 50 {
                self.titleLabel.text = "\(firstResult.identifier.lowercased()) ??? \nConfidence: \(confidence)% 🫣"
                self.titleLabel.font = .italicSystemFont(ofSize: 20)
                self.titleLabel.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
                
            } else {
                self.titleLabel.text = "\(firstResult.identifier.uppercased()) \nConfidence: \(confidence)% 😎"
                self.titleLabel.font = .boldSystemFont(ofSize: 20)
                self.titleLabel.textColor = .lightText
                self.titleLabel.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
                self.titleLabel.layer.cornerRadius = 5
            }
            Alert.showAlert(title: "Error".localized, message: error?.localizedDescription)
        }
    }
    
    let handler = VNImageRequestHandler(ciImage: image)
    
    do {
        try handler.perform([request])
    }
    catch {
        Alert.showAlert(title: "Error".localized, message: error.localizedDescription)
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
        Alert.showAlert(title: "Error".localized, message: "CameraError".localized)
    }
}

private func openGallery() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
        imagePicker.allowsEditing = true
        // imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [UTType.image.identifier as String]
        //imagePicker.dismiss(animated: true)
        self.present(imagePicker, animated: true)
    }
    else {
        Alert.showAlert(title: "Warning".localized, message: "GalleryError".localized)
    }
}

private func showAlertAndExit() {
    let alertController = UIAlertController(
        title: "Error",
        message: "An error occurred. The app will now exit.",
        preferredStyle: .alert
    )
    
    let exitAction = UIAlertAction(title: "Exit", style: .destructive) { _ in
        fatalError("Forced app termination")
    }
    alertController.addAction(exitAction)
    present(alertController, animated: true, completion: nil)
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
    
    titleLabel.text = "SelectSource".localized
    animationView.play()
    animationView.isHidden = false
    imageView.isHidden = true
}

private func addSwipeGestures() {
    
    let gesture = UISwipeGestureRecognizer(target: self, action: #selector(performGesture(_:)))
    imageView.addGestureRecognizer(gesture)
    imageView.isUserInteractionEnabled = true
    
}

private func createFloatingActionButton() {
    
}

@objc private func performGesture(_ gesture: UISwipeGestureRecognizer) {
    if gesture.direction == .left {
        showAnimation()
    } else if gesture.direction == .up{
        FABTapped()
    }
}
}
