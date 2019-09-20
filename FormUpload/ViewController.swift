//
//  ViewController.swift
//  FormUpload
//
//  Created by Lauren White on 9/19/19.
//  Copyright © 2019 Lauren White. All rights reserved.
//

import SwiftyDropbox
import UIKit

class ViewController: UIViewController {
    
    // MARK - UI Outlets
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var majorTextField: UITextField!
    @IBOutlet var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        uploadButton.isEnabled = false
    }
    
    func toggleUploadButtonAvailablity() {
        uploadButton.isEnabled =
            (nameTextField.text != "") &&
            (ageTextField.text != "") &&
            (majorTextField.text != "")
    }

    @IBAction func nameTextFieldChanged(_ sender: Any) {
        toggleUploadButtonAvailablity()
    }
    
    @IBAction func ageTextFieldChanged(_ sender: Any) {
        toggleUploadButtonAvailablity()
    }
    
    @IBAction func majorTextFieldChanged(_ sender: Any) {
        toggleUploadButtonAvailablity()
    }
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        // Upload answers to dropbox
        DropboxClientsManager.authorizeFromController(
            UIApplication.shared,
            controller: self,
            openURL: { (url: URL) -> Void in
                //UIApplication.shared.openURL(url)
                UIApplication.shared.open(url, options: .init(), completionHandler: nil)
        })
    }
}

