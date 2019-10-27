//
//  DropboxSupport.swift
//
//  Created by Lauren White on 10/1/19.
//  Copyright © 2019 Lauren White. All rights reserved.
//

import Foundation
import SwiftyDropbox


/// Custom notifications for Dropbox account login status updates.
extension Notification.Name {
    static let authorizationDidSucceed = Notification.Name("authorizationDidSucceed")
    static let authorizationWasCanceled = Notification.Name("authorizationWasCanceled")
    static let authorizationDidFail = Notification.Name("authorizationDidFail")
}




/// Convenience class for Dropbox integration using SwiftyDropbox framework.
class DropboxSupport {
    
    /// MARK - VARIABLES
    
    /// Dropbox client manager.
    var client: DropboxClient?
    
    /// The view controller from which this support class is being used.
    var viewController: ViewController
    
    
    ///  Initialize the DropboxSupport class from the view controller that is using it.
    ///  Register observers for custrom Dropbox account login status updates.
    init(viewController: ViewController) {
        self.viewController = viewController
        NotificationCenter.default.addObserver(self, selector: #selector(loginDidSucceed), name: .authorizationDidSucceed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginWasCanceled), name: .authorizationWasCanceled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginDidFail(_:)), name: .authorizationDidFail, object: nil)
    }
    
    
    
    /// MARK - METHODS
    
    /// Returns if a Dropbox account is currently logged into or not.
    var isLoggedIn: Bool {
        return DropboxClientsManager.authorizedClient != nil
    }
    
    
    ///
    ///   Start the login process. Call this method from the view controller that you are using
    ///   this support class in.
    ///
    func initiateLoginRequest() {
        DropboxClientsManager.authorizeFromController(
            UIApplication.shared,
            controller: viewController,
            openURL: { (url: URL) -> Void in
                UIApplication.shared.open(url, options: .init(), completionHandler: nil)
        })
    }
    
    
    ///
    ///   Complete the login request by opening the Dropbox login screen in a browser window.
    ///   Call this method from the app delegate.
    ///
    /// - parameter url: The url that directs to the browser Dropbox login screen.
    ///
    static func completeLoginRequest(url: URL) {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                NotificationCenter.default.post(name: .authorizationDidSucceed, object: nil)
            case .cancel:
                NotificationCenter.default.post(name: .authorizationWasCanceled, object: nil)
            case .error(_, let description):
                NotificationCenter.default.post(name: .authorizationDidFail, object: nil, userInfo: ["error": description])
            }
        }
    }
    
    
    ///
    ///   Upload any data / file to Dropbox.
    ///
    /// - parameter data: The file to upload, as a Data object.
    /// - parameter fileName: The name the file should be saved under.
    /// - parameter folders: An array of any folders the file should be in.
    /// - parameter mode: The file write mode (add, overwrite, update).
    ///
    func uploadDataToDropbox(data: Data, fileName: String, folders: [String] = [], mode: Files.WriteMode = .add) {
        // Generate the file path using the given file folders and file name
        var pathComponents = folders
        pathComponents.append(fileName)
        let filePath =  "/" + "\(pathComponents.joined(separator: "/"))"
        
        // Access authorized client from log in
        client = DropboxClientsManager.authorizedClient
        
        // Make request for file upload, adding a new file by default
        let request = client?.files.upload(path: filePath, mode: mode, input: data)
            .response { response, error in
                if let response = response {
                    self.presentUploadSuccessAlert()
                    print(response)
                } else if let error = error {
                    self.presentUploadFailureAlert()
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
        }
    }
    
    
    /// Called when observer receives notifcation that the user logged in.
    /// Displays an alert updating the user.
    @objc func loginDidSucceed() {
        presentLoginSuccessAlert()
    }

    /// Called when observer receives notifcation that the user canceled logged in.
    /// Displays an alert updating the user.
    @objc func loginWasCanceled() {
        presentLoginWasCanceledAlert()
    }
    
    /// Called when observer receives notifcation that the user failed to login.
    /// Displays an alert updating the user.
    @objc func loginDidFail(_ notification: Notification) {
        guard let data = notification.userInfo as? [String: String],
          let error = data["error"]
        else { return }
        presentLoginFailedAlert(error: error)
    }
    
    
    
    /// MARK - ALERTS
    
    private func presentUploadSuccessAlert() {
        let alert = UIAlertController(title: "Upload Success", message: "The file was successfully uploaded to Dropbox.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The file was successfully uploaded to Dropbox.")
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func presentUploadFailureAlert() {
        let alert = UIAlertController(title: "Upload Failure", message: "Failed to upload file to Dropbox.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .destructive, handler: { _ in
            NSLog("The file was successfully uploaded to Dropbox.")
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func presentLoginSuccessAlert() {
        let alert = UIAlertController(title: "Login Success", message: "Successfully logged into Dropbox account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Success! User is logged into Dropbox.")
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func presentLoginWasCanceledAlert() {
        let alert = UIAlertController(title: "Login Canceled", message: "Authorization flow was manually canceled by user.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("Authorization flow was manually canceled by user!")
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func presentLoginFailedAlert(error: String) {
        let alert = UIAlertController(title: "Login Failed", message: "There was an error with logging into Dropbox account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .destructive, handler: { _ in
            NSLog("Login failed with error: \(error)")
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
}
