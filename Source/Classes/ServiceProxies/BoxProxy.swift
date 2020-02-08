//
//  BoxProxy.swift
//  Importing
//
//  Created by Alexander Karpov on 28.01.2020.
//  Copyright © 2020 Alexander Karpov. All rights reserved.
//

import BoxSDK
import UIKit
import Combine

fileprivate extension String {
    static var root: String {
        BoxSDK.Constants.rootFolder
    }
}

class BoxProxy: BaseProxy, IServiceProxy {
    private var progressHandler: ProgressHandler?
    
    private var completionHandler: DataHandler?
    
    private var selectionHandler: SelectionHandler?
    
    private var cancelationHandler: CancelationHandler?
    
    private var authDelegate: Block<StringResult, Void>?
    
    var name: String {
        "Box"
    }
    
    var icon: UIImage {
        R.image.boxIcon()!
    }
    
    private var box: BoxSDK?
    
    private var boxClient: BoxClient?
    
    func awake() {
        box = .init()
    }
    
    func authorize(on vc: UIViewController, authDelegate: @escaping Block<Result<String, Error>, Void>) {
        authState = .inProgress
//        if #available(iOS 13, *) {
//            box.get
//            box?.getOAuth2Client(tokenStore: KeychainTokenStore(), context: vc) { result in
//                switch result {
//                case .success(let client):
//                    boxClient = client
//                    client.users.getCurrent { usersResult in
//                        completion(usersResult.mapError{$0})
//                    }
//                case .failure(let error):
//                    #warning("need to handle cancel of authorization")
//                    completion(.failure(error))
//                }
//            }
//        } else {
            box?.getOAuth2Client(tokenStore: KeychainTokenStore()) { result in
                switch result {
                case .success(let client):
                    self.boxClient = client
                    client.users.getCurrent { usersResult in
                        authDelegate(usersResult.mapError{$0}.map {
                            self.authState = .authorized
                            return $0.id})
                    }
                case .failure(let error):
                    authDelegate(.failure(error))
                }
            }
//        }
    }
    
    func handle(redirect url: URL?) {
        print(url)
    }
    
    func fetchFiles(for path: String?, callback: @escaping FetchResult) {
        
    }
    
    func searchFiles(for path: String, callback: @escaping FetchResult) {
        
    }
    
    func download(_ file: File) -> IDownloadRequest? {
        nil
    }
    
    func progress(_ progressHandler: @escaping ProgressHandler) -> Self {
        return self
    }
    
    func response(_ completionHandler: DataHandler?) -> Self {
        return self
    }
    
    func didSelect(_ selectionHandler: @escaping SelectionHandler) -> Self {
        return self
    }
    
    func didCancel(_ cancelationHandler: @escaping CancelationHandler) -> Self {
        return self
    }
}
