//
//  LandingViewController.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/06/20.
//

import UIKit
import Lottie

class LandingViewController: UIViewController {

    
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {

      super.viewDidLoad()
      
      // 2. Start LottieAnimationView with animation name (without extension)
      
      animationView = .init(name: "lottieAnimmation")
      
      animationView!.frame = view.bounds
      
      // 3. Set animation content mode
      
      animationView!.contentMode = .scaleAspectFit
      
      // 4. Set animation loop mode
      
      animationView!.loopMode = .loop
      
      // 5. Adjust animation speed
      
      animationView!.animationSpeed = 0.5
      
      view.addSubview(animationView!)
      
      // 6. Play animation
      
      animationView!.play()
      
    }
    
    func setupTitle() {
        let title = "Eyedentify"
        var charIndex = 0
        titleLabel.text = ""
        for letter in title {
            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(charIndex) , repeats: true) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }

}
