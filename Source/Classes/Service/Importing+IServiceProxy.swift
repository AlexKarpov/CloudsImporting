//
//  Importing+IServiceProxy.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import UIKit

extension Import: IServiceProxy {
    public var icon: UIImage {
        service.icon
    }
    
    public var authState: AuthState {
        service.authState
    }
    
    public func didCancel(_ cancelationHandler: @escaping CancelationHandler) -> Self {
        service.didCancel(cancelationHandler)
        return self
    }
    
    public func didSelect(_ selectionHandler: @escaping Block<File, Void>) -> Self {
        service.didSelect(selectionHandler)
        return self
    }
    
//    public func progress(_ progressHandler: @escaping ProgressHandler) -> Self {
//        service.progress(progressHandler)
//        return self
//    }
//    
//    public func response(_ completionHandler: DataHandler?) -> Self {
//        service.response(completionHandler)
//        return self
//    }
    
    public var name: String {
        service.name
    }
    
    public func awake() {
        service.awake()
    }
    
    public func authorize(on vc: UIViewController, authDelegate: @escaping Block<Result<String, Error>, Void>) {
        service.authorize(on: vc, authDelegate: authDelegate)
    }
    
    public func handle(redirect url: URL?) {
        service.handle(redirect: url)
    }
    
    public func fetchFiles(for path: String?, callback: @escaping FetchResult) {
        service.fetchFiles(for: path, callback: callback)
    }
    
    public func searchFiles(for path: String, callback: @escaping FetchResult) {
        service.searchFiles(for: path, callback: callback)
    }
    
    public func download(_ file: File) -> IDownloadRequest? {
        service.download(file)
    }
}
