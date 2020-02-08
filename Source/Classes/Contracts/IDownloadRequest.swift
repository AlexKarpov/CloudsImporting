//
//  DownloadRequest.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

public protocol IDownloadRequest {
    
    var url: URL? { get }
    
    @discardableResult func progress(_ progressHandler: @escaping ProgressHandler) -> Self
    
    @discardableResult func response(_ completionHandler: DataHandler?) -> Self
}

public extension IDownloadRequest {
    func handleData(at handler: IFileDownloadHandler) {
        response { result in
            handler.requestDidComplete(with: result)
        }
    }
}

public protocol IFileDownloadHandler {
    func requestDidComplete(with result: Swift.Result<DownloadResult?, DownloadError>)
}
