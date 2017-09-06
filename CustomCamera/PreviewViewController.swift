//
//  PreviewViewController.swift
//  CustomCamera
//
//  Created by Clara Carneiro on 7/27/17.
//  Copyright © 2017 Clara Carneiro. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    // status bar with white text color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var image : UIImage!
    @IBOutlet var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
        // Do any additional setup after loading the view.
    }

    
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        saveAlert()
        dismiss(animated: true, completion: nil)
    }
    
    func saveAlert () {
        let alertController = UIAlertController(title: "Image Saved!", message: "Your picture was successfully saved.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func cancelButtoun_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
