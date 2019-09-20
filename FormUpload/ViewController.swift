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
    
    // Dropbox variables
    var client: DropboxClient?
    
    // File variables
    let fileName = "responses.txt"
    
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
        // Upload form responses to dropbox
        uploadFileToDropbox()
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        DropboxClientsManager.authorizeFromController(
            UIApplication.shared,
            controller: self,
            openURL: { (url: URL) -> Void in
                UIApplication.shared.open(url, options: .init(), completionHandler: nil)
        })
    }
    
    func condenseRepsonsesToString() -> String {
        let name = nameTextField.text ?? "N/A"
        let age = ageTextField.text ?? "N/A"
        let major = majorTextField.text ?? "N/A"
        return "Name:\(name)  Age:\(age)  Major:\(major)"
    }
    
    func uploadFileToDropbox() {
        let responses = condenseRepsonsesToString()
        let fileData = responses.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let filePath = "/\(fileName)"
        client = DropboxClientsManager.authorizedClient
        
        let _ = client?.files.upload(path: filePath, mode: .overwrite,input: fileData)
            .response { response, error in
                if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
        }
    }
}

