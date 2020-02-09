//
//  ViewController.swift
//  FormUpload
//
//  Created by Lauren White on 9/19/19.
//  Copyright © 2019 Lauren White. All rights reserved.
//

import UIKit
import Network

class ViewController: UIViewController {
    
    // Dropbox variables
    var dropboxSupport: DropboxSupport?
    
    let database = Database()
    
    // File variables
    var fileName: String?
    
    var timestamp: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    // MARK - UI Outlets
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var majorTextField: UITextField!
    @IBOutlet var uploadButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        uploadButton.isEnabled = false
        dropboxSupport = DropboxSupport(viewController: self)
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
        fileName = "responses[\(timestamp)].txt"
        let responses = condenseRepsonsesToString()
        let fileData = responses.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let file = TextFile(name: fileName ?? "responses.txt", data: fileData)
        database.addTextFile(file: file)
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        // Open Safari browser window with dropbox login screen
        dropboxSupport?.initiateLoginRequest()
    }
    
    // Record responses as single string, to be written into .txt file
    func condenseRepsonsesToString() -> String {
        let name = nameTextField.text ?? "N/A"
        let age = ageTextField.text ?? "N/A"
        let major = majorTextField.text ?? "N/A"
        return "Name:\(name)  Age:\(age)  Major:\(major)"
    }
}

