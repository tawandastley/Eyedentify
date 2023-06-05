//
//  ViewController.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/06/04.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Click camera icon to begin"
        imagePicker.delegate = self
      //  imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("i am tapped")
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            guard let image = CIImage(image: pickedImage) else {
                return
            }
            detectImage(image: image)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func detectImage(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: SqueezeNet(()).model) else {
            fatalError()
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError()
            }
            if let firstResult = results.first {
                let confidence = (firstResult.confidence) * 100
                self.titleLabel.isHidden = false
                self.titleLabel.text = "\(firstResult.identifier.uppercased()) with \(confidence) % confidence"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            fatalError()
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
            self.present(self.imagePicker, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
            self.present(self.imagePicker, animated: true)
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(imagePicker, animated: true)
        self.present(alert, animated: true, completion: nil)
       
    }
}

extension SqueezeNet {
    
    convenience init(_ foo: Void) {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
}

extension ViewController {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //imagePicker.dismiss(animated: true)
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
