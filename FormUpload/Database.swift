//
//  Database.swift
//  FormUpload
//
//  Created by Lauren White on 2/9/20.
//  Copyright © 2020 Lauren White. All rights reserved.
//

import Foundation

class TextFile {
    let name: String
    let data: Data
    var uploaded: Bool
    
    init(name: String, data: Data) {
        self.name = name
        self.data = data
        self.uploaded = false
    }
}

class Database {
    
    var files: [TextFile] = []
    
    let dropboxSupport = DropboxSupport(viewController: nil)
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(uploadOfflineDocuments), name: .networkConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doSomething), name: .noConnection, object: nil)
    }
    
    @objc func uploadOfflineDocuments() {
        for file in files {
            if !file.uploaded {
                dropboxSupport.uploadDataToDropbox(data: file.data, fileName: file.name, mode: .overwrite) { (result: Bool) in
                    file.uploaded = result
                }
            }
        }
    }
    
    @objc func doSomething() {
        
    }
    
    func addTextFile(file: TextFile) {
        files.append(file)
        uploadOfflineDocuments()
    }
}
