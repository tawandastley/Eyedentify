//
//  ResultsViewController.swift
//  Eyedentify
//
//  Created by Tawanda Chandiwana on 2023/08/04.
//

import UIKit

class ResultsViewController: UIViewController {
    
    var result: String?
    
    @IBOutlet weak var resultsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsLabel.text = result ?? ""
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
