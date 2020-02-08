//
//  DownloadRequest.swift
//  Importing
//
//  Created by Stas Lavruk on 26.11.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

class DownloadRequest: IDownloadRequest {
    var url: URL?
    
    var dataHandler: DataHandler?
    
    var progressHandler: ProgressHandler?
    
    init(_ decorator: (DownloadRequest) -> Void) {
        decorator(self)
    }
    
    func progress(_ progressHandler: @escaping ProgressHandler) -> Self {
        self.progressHandler = progressHandler
        return self
    }
    
    func response(_ completionHandler: DataHandler?) -> Self {
        self.dataHandler = completionHandler
        return self
    }
}
